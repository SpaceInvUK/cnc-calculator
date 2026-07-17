<?php
/**
 * Plugin Name: FAST CNC — Order Bridge (Kabacal)
 * Description: When an order reaches "processing" (paid), builds a kabacal-order/v1 JSON payload and POSTs it to the production intake endpoint (Supabase Edge Function). Without FCNC_BRIDGE_URL/FCNC_BRIDGE_SECRET in wp-config.php it stores the payload on the order and logs, so the site keeps working with no backend configured.
 * Version: 1.0.0
 * Author: FAST CNC
 */

defined( 'ABSPATH' ) || exit;

class FastCNC_Order_Bridge {

	const SCHEMA  = 'kabacal-order/v1';
	const VERSION = '1.0.0';

	public function __construct() {
		add_action( 'woocommerce_order_status_processing', array( $this, 'dispatch' ), 20, 1 );
	}

	/* ---------- payload ---------- */

	/**
	 * Order → kabacal-order/v1 array. Reads the machine-readable `_fcnc_data`
	 * item meta (door-prep >= 2.1); falls back to parsing the display meta so
	 * orders placed before 2.1 still produce a payload.
	 */
	public static function build_payload( WC_Order $order ) {
		$items = array();
		foreach ( $order->get_items( 'line_item' ) as $item ) {
			$product_id = (int) $item->get_product_id();
			$qty        = (int) $item->get_quantity();
			$line_total = (float) $item->get_total();

			$data = json_decode( (string) $item->get_meta( '_fcnc_data', true ), true );
			if ( ! is_array( $data ) ) {
				$data = self::parse_display_meta( $item );
			}

			$size_data = json_decode( (string) get_post_meta( $product_id, '_fcnc_size_data', true ), true );
			$product   = $item->get_product();
			$slug      = $product ? $product->get_slug() : '';

			$items[] = array(
				'product_id'        => $product_id,
				'name'              => $item->get_name(),
				'kind'              => is_array( $size_data ) && ! empty( $size_data['type'] ) ? $size_data['type'] : 'door',
				'style'             => preg_replace( '/-door$/', '', $slug ),
				'qty'               => $qty,
				'h_mm'              => isset( $data['h'] ) ? (int) $data['h'] : null,
				'w_mm'              => isset( $data['w'] ) ? (int) $data['w'] : null,
				't_mm'              => isset( $data['t'] ) ? (int) $data['t'] : null,
				'finish'            => isset( $data['finish'] ) ? $data['finish'] : null,
				'hinge_holes'       => isset( $data['holes'] ) ? (int) preg_replace( '/\D/', '', (string) $data['holes'] ) : 0,
				'hole_positions'    => isset( $data['positions'] ) ? $data['positions'] : null,
				'hinge_side'        => isset( $data['side'] ) ? $data['side'] : null,
				'soft_close_hinges' => isset( $data['hinges'] ) ? (int) $data['hinges'] : 0,
				'cnc_notes'         => isset( $data['notes'] ) ? $data['notes'] : '',
				'unit_price'        => $qty > 0 ? number_format( $line_total / $qty, 2, '.', '' ) : null,
				'line_total'        => number_format( $line_total, 2, '.', '' ),
				'prep_cost'         => isset( $data['prep_cost'] ) ? number_format( (float) $data['prep_cost'], 2, '.', '' ) : '0.00',
			);
		}

		return array(
			'schema'         => self::SCHEMA,
			'source'         => 'woocommerce',
			'site_url'       => home_url(),
			'bridge_version' => self::VERSION,
			'order'          => array(
				'id'             => $order->get_id(),
				'number'         => $order->get_order_number(),
				'status'         => $order->get_status(),
				'currency'       => $order->get_currency(),
				'total'          => $order->get_total(),
				'created_gmt'    => $order->get_date_created() ? $order->get_date_created()->setTimezone( new DateTimeZone( 'UTC' ) )->format( 'Y-m-d\TH:i:s\Z' ) : null,
				'payment_method' => $order->get_payment_method(),
				'transaction_id' => $order->get_transaction_id(),
				'customer_note'  => $order->get_customer_note(),
				'customer'       => array(
					'first_name'       => $order->get_billing_first_name(),
					'last_name'        => $order->get_billing_last_name(),
					'email'            => $order->get_billing_email(),
					'phone'            => $order->get_billing_phone(),
					'billing_address'  => self::format_address( $order, 'billing' ),
					'shipping_address' => self::format_address( $order, $order->has_shipping_address() ? 'shipping' : 'billing' ),
				),
			),
			'items'          => $items,
		);
	}

	/** Fallback for pre-2.1 orders: rebuild numbers from the display meta. */
	private static function parse_display_meta( WC_Order_Item $item ) {
		$data = array();
		if ( preg_match( '/(\d+)\s*x\s*(\d+)/', (string) $item->get_meta( 'Size', true ), $m ) ) {
			$data['h'] = (int) $m[1];
			$data['w'] = (int) $m[2];
		}
		if ( preg_match( '/(\d+)/', (string) $item->get_meta( 'Thickness', true ), $m ) ) {
			$data['t'] = (int) $m[1];
		}
		$data['finish']    = $item->get_meta( 'Finish', true );
		$data['holes']     = $item->get_meta( 'Hinge holes', true );
		$data['positions'] = $item->get_meta( 'Hole positions', true );
		$data['side']      = $item->get_meta( 'Hinge side', true );
		$data['hinges']    = (int) $item->get_meta( 'Soft-close hinges', true );
		$data['notes']     = $item->get_meta( 'CNC notes', true );
		$data['prep_cost'] = (float) $item->get_meta( '_fcnc_prep_cost', true );
		return $data;
	}

	private static function format_address( WC_Order $order, $type ) {
		$get   = "get_{$type}_address_1";
		$parts = array_filter( array(
			$order->$get(),
			$order->{"get_{$type}_address_2"}(),
			$order->{"get_{$type}_city"}(),
			$order->{"get_{$type}_postcode"}(),
			$order->{"get_{$type}_country"}(),
		) );
		return implode( ', ', $parts );
	}

	/* ---------- dispatch ---------- */

	public function dispatch( $order_id ) {
		$order = wc_get_order( $order_id );
		if ( ! $order ) {
			return;
		}
		if ( $order->get_meta( '_fcnc_bridge_sent', true ) ) {
			return; // idempotent: already delivered
		}

		$payload = self::build_payload( $order );
		$logger  = wc_get_logger();

		if ( ! defined( 'FCNC_BRIDGE_URL' ) || ! defined( 'FCNC_BRIDGE_SECRET' ) ) {
			$order->update_meta_data( '_fcnc_bridge_payload', wp_json_encode( $payload ) );
			$order->save();
			$logger->info( "Order {$order_id}: bridge not configured (FCNC_BRIDGE_URL/SECRET missing); payload stored on order meta.", array( 'source' => 'fastcnc-bridge' ) );
			return;
		}

		$response = wp_remote_post( FCNC_BRIDGE_URL, array(
			'timeout' => 15,
			'headers' => array(
				'Content-Type'  => 'application/json',
				'X-FCNC-Secret' => FCNC_BRIDGE_SECRET,
			),
			'body'    => wp_json_encode( $payload ),
		) );

		if ( is_wp_error( $response ) ) {
			$logger->error( "Order {$order_id}: bridge POST failed: " . $response->get_error_message(), array( 'source' => 'fastcnc-bridge' ) );
			$order->add_order_note( 'Kabacal bridge: delivery FAILED — ' . $response->get_error_message() );
			return;
		}

		$code = (int) wp_remote_retrieve_response_code( $response );
		if ( $code >= 200 && $code < 300 ) {
			$order->update_meta_data( '_fcnc_bridge_sent', gmdate( 'c' ) );
			$order->save();
			$order->add_order_note( 'Kabacal bridge: order delivered to production intake.' );
		} else {
			$logger->error( "Order {$order_id}: bridge POST returned HTTP {$code}: " . wp_remote_retrieve_body( $response ), array( 'source' => 'fastcnc-bridge' ) );
			$order->add_order_note( "Kabacal bridge: delivery FAILED — HTTP {$code}." );
		}
	}
}

new FastCNC_Order_Bridge();
