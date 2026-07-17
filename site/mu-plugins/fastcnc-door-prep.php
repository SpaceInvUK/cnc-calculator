<?php
/**
 * Plugin Name: FAST CNC — Custom Size & Door Preparation
 * Description: Type-your-size ordering (height x width + thickness) with band pricing for doors and wall panels, plus CNC door-preparation options (hinges, finish). Prices resolve server-side from the product's _fcnc_size_data meta.
 * Version: 2.0.0
 * Author: FAST CNC
 */

defined( 'ABSPATH' ) || exit;

class FastCNC_Custom_Size {

	const PRICE_CUSTOM_POS = 5.0;  // custom hinge-hole positions, per door
	const PRICE_PER_HINGE  = 5.0;  // soft-close hinge, each

	public function __construct() {
		add_action( 'woocommerce_before_add_to_cart_button', array( $this, 'render_fields' ), 5 );
		add_filter( 'woocommerce_add_to_cart_validation', array( $this, 'validate' ), 10, 3 );
		add_filter( 'woocommerce_add_cart_item_data', array( $this, 'capture' ), 10, 2 );
		add_filter( 'woocommerce_get_item_data', array( $this, 'cart_display' ), 10, 2 );
		add_action( 'woocommerce_before_calculate_totals', array( $this, 'apply_price' ), 20 );
		add_action( 'woocommerce_checkout_create_order_line_item', array( $this, 'order_meta' ), 10, 3 );
		add_filter( 'woocommerce_get_price_html', array( $this, 'from_price_html' ), 10, 2 );
	}

	/* ---------- data ---------- */

	private function size_data( $product_id ) {
		$raw = get_post_meta( $product_id, '_fcnc_size_data', true );
		if ( ! $raw ) {
			return null;
		}
		$data = json_decode( $raw, true );
		return ( $data && ! empty( $data['bands'] ) ) ? $data : null;
	}

	/**
	 * Cheapest qualifying band price for typed size + thickness.
	 * A band qualifies if it can contain the piece in either orientation.
	 */
	public static function band_price( $data, $h, $w, $t ) {
		$best = null;
		foreach ( $data['bands'] as $size => $prices ) {
			if ( ! isset( $prices[ $t ] ) ) {
				continue;
			}
			list( $bh, $bw ) = array_map( 'intval', explode( 'x', $size ) );
			$fits = ( $bh >= $h && $bw >= $w ) || ( $bh >= $w && $bw >= $h );
			if ( $fits ) {
				$p = (float) $prices[ $t ];
				if ( null === $best || $p < $best ) {
					$best = $p;
				}
			}
		}
		return $best; // null = out of range
	}

	private static function max_dims( $data ) {
		$long = 0;
		$short = 0;
		foreach ( $data['bands'] as $size => $prices ) {
			list( $bh, $bw ) = array_map( 'intval', explode( 'x', $size ) );
			$long  = max( $long, $bh, $bw );
			$short = max( $short, min( $bh, $bw ) );
		}
		return array( $long, $short );
	}

	/* ---------- product page ---------- */

	public function render_fields() {
		global $product;
		if ( ! $product ) {
			return;
		}
		$data = $this->size_data( $product->get_id() );
		if ( ! $data ) {
			return;
		}
		list( $max_long, $max_short ) = self::max_dims( $data );
		$is_door = ( 'door' === $data['type'] );
		$json    = esc_attr( wp_json_encode( array( 'bands' => $data['bands'] ) ) );
		?>
		<div class="fcnc-size" data-bands="<?php echo $json; ?>"
			style="border:1px solid #e3e0d9;border-radius:8px;padding:18px 20px;margin:6px 0 18px;background:#faf9f6;">
			<p style="font-weight:600;margin:0 0 12px;font-size:15px;">Your exact size
				<span style="font-weight:400;color:#777;">— type it, we cut it. No premium for custom sizes.</span></p>

			<div style="display:flex;gap:18px;flex-wrap:wrap;align-items:flex-end;">
				<div>
					<label style="display:block;font-size:13px;font-weight:600;margin-bottom:4px;">Height (mm)</label>
					<input type="number" name="fcnc_h" class="fcnc-h" min="100" max="<?php echo (int) $max_long; ?>" step="1"
						placeholder="e.g. 720" style="width:130px;" required>
				</div>
				<div>
					<label style="display:block;font-size:13px;font-weight:600;margin-bottom:4px;">Width (mm)</label>
					<input type="number" name="fcnc_w" class="fcnc-w" min="100" max="<?php echo (int) $max_long; ?>" step="1"
						placeholder="e.g. 450" style="width:130px;" required>
				</div>
				<div>
					<label style="display:block;font-size:13px;font-weight:600;margin-bottom:4px;">Thickness</label>
					<select name="fcnc_t" class="fcnc-t" style="width:120px;">
						<?php foreach ( $data['thicknesses'] as $i => $t ) : ?>
							<option value="<?php echo esc_attr( $t ); ?>" <?php selected( $i, count( $data['thicknesses'] ) - 1 ); ?>>
								<?php echo esc_html( $t ); ?> mm
							</option>
						<?php endforeach; ?>
					</select>
				</div>
				<div class="fcnc-price-box" style="min-width:150px;">
					<span style="display:block;font-size:12px;color:#777;">Price for your size</span>
					<span class="fcnc-price" style="font-size:22px;font-weight:700;">&mdash;</span>
				</div>
			</div>
			<p class="fcnc-range-note" style="margin:10px 0 0;font-size:12px;color:#999;">
				Up to <?php echo (int) $max_long; ?> &times; <?php echo (int) $max_short; ?> mm.
				Larger? <a href="/#wpcf7-f131-p6-o1">Ask us</a> &mdash; we cut big.
			</p>
		</div>
		<?php if ( $is_door ) : ?>
		<div class="fastcnc-prep" style="border:1px solid #e3e0d9;border-radius:8px;padding:18px 20px;margin:0 0 22px;background:#faf9f6;">
			<p style="font-weight:600;margin:0 0 12px;font-size:15px;">CNC preparation <span style="font-weight:400;color:#777;">&mdash; optional, all in one place</span></p>

			<p style="margin:0 0 6px;font-size:13px;font-weight:600;">Finish</p>
			<label style="margin-right:16px;font-size:13px;"><input type="radio" name="fcnc_finish" value="Primed white" checked> Primed white (included)</label>
			<label style="font-size:13px;"><input type="radio" name="fcnc_finish" value="Unprimed (sanded)"> Unprimed, sanded</label>

			<p style="margin:14px 0 6px;font-size:13px;font-weight:600;">Hinge holes <span style="font-weight:400;color:#777;">(35&nbsp;mm cup, 87&nbsp;mm centres)</span></p>
			<select name="fcnc_holes" style="max-width:260px;">
				<option value="None">No drilling</option>
				<option value="2 holes">2 holes</option>
				<option value="3 holes">3 holes</option>
				<option value="4 holes">4 holes</option>
			</select>

			<div style="display:flex;gap:28px;flex-wrap:wrap;margin-top:12px;">
				<div>
					<p style="margin:0 0 6px;font-size:13px;font-weight:600;">Hole positions</p>
					<label style="display:block;font-size:13px;"><input type="radio" name="fcnc_positions" value="Standard" checked> Standard</label>
					<label style="display:block;font-size:13px;"><input type="radio" name="fcnc_positions" value="Custom"> Custom (+<?php echo wp_kses_post( wc_price( self::PRICE_CUSTOM_POS ) ); ?>)</label>
				</div>
				<div>
					<p style="margin:0 0 6px;font-size:13px;font-weight:600;">Hinge side</p>
					<label style="display:block;font-size:13px;"><input type="radio" name="fcnc_side" value="Left" checked> Left</label>
					<label style="display:block;font-size:13px;"><input type="radio" name="fcnc_side" value="Right"> Right</label>
				</div>
				<div>
					<p style="margin:0 0 6px;font-size:13px;font-weight:600;">Soft-close hinges <span style="font-weight:400;color:#777;">(<?php echo wp_kses_post( wc_price( self::PRICE_PER_HINGE ) ); ?> each)</span></p>
					<select name="fcnc_hinges" style="max-width:200px;">
						<option value="0">Not needed</option>
						<option value="2">2 hinges</option>
						<option value="3">3 hinges</option>
						<option value="4">4 hinges</option>
					</select>
				</div>
			</div>

			<p style="margin:14px 0 6px;font-size:13px;font-weight:600;">Notes for our CNC team <span style="font-weight:400;color:#777;">(optional)</span></p>
			<textarea name="fcnc_notes" rows="2" maxlength="400" style="width:100%;font-size:13px;" placeholder="e.g. holes at 100mm and 700mm from bottom"></textarea>
		</div>
		<?php endif; ?>
		<script>
		(function(){
			var box = document.querySelector('.fcnc-size');
			if (!box) return;
			var bands = JSON.parse(box.getAttribute('data-bands')).bands;
			var h = box.querySelector('.fcnc-h'), w = box.querySelector('.fcnc-w'),
			    t = box.querySelector('.fcnc-t'), out = box.querySelector('.fcnc-price');
			function calc(){
				var H = parseInt(h.value,10), W = parseInt(w.value,10), T = t.value, best = null;
				if (!H || !W) { out.textContent = '—'; return; }
				for (var size in bands) {
					var p = bands[size][T];
					if (p === undefined) continue;
					var d = size.split('x'), bh = +d[0], bw = +d[1];
					if ((bh>=H && bw>=W) || (bh>=W && bw>=H)) {
						p = parseFloat(p);
						if (best === null || p < best) best = p;
					}
				}
				out.textContent = (best === null) ? 'Out of range' : '£' + best.toFixed(2);
				out.style.color = (best === null) ? '#c0392b' : '';
			}
			[h,w].forEach(function(el){ el.addEventListener('input', calc); });
			t.addEventListener('change', calc);
		})();
		</script>
		<?php
	}

	/* ---------- validation & capture ---------- */

	public function validate( $passed, $product_id, $qty ) {
		$data = $this->size_data( $product_id );
		if ( ! $data ) {
			return $passed;
		}
		$h = isset( $_POST['fcnc_h'] ) ? absint( $_POST['fcnc_h'] ) : 0;
		$w = isset( $_POST['fcnc_w'] ) ? absint( $_POST['fcnc_w'] ) : 0;
		$t = isset( $_POST['fcnc_t'] ) ? preg_replace( '/\D/', '', wp_unslash( $_POST['fcnc_t'] ) ) : '';

		if ( $h < 100 || $w < 100 ) {
			wc_add_notice( 'Please enter the height and width in millimetres (minimum 100 mm).', 'error' );
			return false;
		}
		if ( null === self::band_price( $data, $h, $w, $t ) ) {
			wc_add_notice( 'That size/thickness is outside our online range &mdash; please contact us for a custom quote.', 'error' );
			return false;
		}
		return $passed;
	}

	public function capture( $cart_item_data, $product_id ) {
		$data = $this->size_data( $product_id );
		if ( ! $data ) {
			return $cart_item_data;
		}
		$h = absint( $_POST['fcnc_h'] ?? 0 );
		$w = absint( $_POST['fcnc_w'] ?? 0 );
		$t = preg_replace( '/\D/', '', wp_unslash( $_POST['fcnc_t'] ?? '' ) );

		$cart_item_data['fcnc_size'] = array(
			'h'     => $h,
			'w'     => $w,
			't'     => $t,
			'price' => self::band_price( $data, $h, $w, $t ),
		);

		// Door preparation extras (doors only)
		if ( 'door' === $data['type'] ) {
			$allowed_finish = array( 'Primed white', 'Unprimed (sanded)' );
			$allowed_holes  = array( 'None', '2 holes', '3 holes', '4 holes' );
			$allowed_pos    = array( 'Standard', 'Custom' );
			$allowed_side   = array( 'Left', 'Right' );

			$finish = sanitize_text_field( wp_unslash( $_POST['fcnc_finish'] ?? 'Primed white' ) );
			$holes  = sanitize_text_field( wp_unslash( $_POST['fcnc_holes'] ?? 'None' ) );
			$pos    = sanitize_text_field( wp_unslash( $_POST['fcnc_positions'] ?? 'Standard' ) );
			$side   = sanitize_text_field( wp_unslash( $_POST['fcnc_side'] ?? 'Left' ) );
			$hinges = min( 4, absint( $_POST['fcnc_hinges'] ?? 0 ) );
			$notes  = sanitize_textarea_field( wp_unslash( $_POST['fcnc_notes'] ?? '' ) );

			$prep = array(
				'finish' => in_array( $finish, $allowed_finish, true ) ? $finish : 'Primed white',
				'holes'  => in_array( $holes, $allowed_holes, true ) ? $holes : 'None',
				'side'   => in_array( $side, $allowed_side, true ) ? $side : 'Left',
				'hinges' => $hinges,
				'notes'  => mb_substr( $notes, 0, 400 ),
			);
			$prep['positions']  = ( 'None' === $prep['holes'] ) ? '-' : ( in_array( $pos, $allowed_pos, true ) ? $pos : 'Standard' );
			$prep['extra_cost'] = ( 'Custom' === $prep['positions'] ? self::PRICE_CUSTOM_POS : 0 )
				+ ( $prep['hinges'] * self::PRICE_PER_HINGE );

			$cart_item_data['fcnc_prep'] = $prep;
		}
		return $cart_item_data;
	}

	/* ---------- cart / totals / order ---------- */

	public function cart_display( $item_data, $cart_item ) {
		if ( ! empty( $cart_item['fcnc_size'] ) ) {
			$s = $cart_item['fcnc_size'];
			$item_data[] = array( 'key' => 'Size', 'value' => $s['h'] . ' x ' . $s['w'] . ' mm' );
			$item_data[] = array( 'key' => 'Thickness', 'value' => $s['t'] . ' mm' );
		}
		if ( ! empty( $cart_item['fcnc_prep'] ) ) {
			$p = $cart_item['fcnc_prep'];
			$item_data[] = array( 'key' => 'Finish', 'value' => $p['finish'] );
			$item_data[] = array( 'key' => 'Hinge holes', 'value' => $p['holes'] . ( 'None' === $p['holes'] ? '' : ', ' . $p['positions'] . ' positions, ' . $p['side'] . ' side' ) );
			if ( $p['hinges'] > 0 ) {
				$item_data[] = array( 'key' => 'Soft-close hinges', 'value' => $p['hinges'] . ' supplied' );
			}
			if ( '' !== $p['notes'] ) {
				$item_data[] = array( 'key' => 'CNC notes', 'value' => $p['notes'] );
			}
			if ( $p['extra_cost'] > 0 ) {
				$item_data[] = array( 'key' => 'Preparation', 'value' => '+' . wp_strip_all_tags( wc_price( $p['extra_cost'] ) ) );
			}
		}
		return $item_data;
	}

	public function apply_price( $cart ) {
		if ( is_admin() && ! defined( 'DOING_AJAX' ) ) {
			return;
		}
		foreach ( $cart->get_cart() as $item ) {
			$price = null;
			if ( ! empty( $item['fcnc_size'] ) && null !== $item['fcnc_size']['price'] ) {
				$price = (float) $item['fcnc_size']['price'];
			}
			if ( null !== $price && ! empty( $item['fcnc_prep']['extra_cost'] ) ) {
				$price += (float) $item['fcnc_prep']['extra_cost'];
			}
			if ( null !== $price ) {
				$item['data']->set_price( $price );
			}
		}
	}

	public function order_meta( $order_item, $cart_item_key, $values ) {
		if ( ! empty( $values['fcnc_size'] ) ) {
			$s = $values['fcnc_size'];
			$order_item->add_meta_data( 'Size', $s['h'] . ' x ' . $s['w'] . ' mm' );
			$order_item->add_meta_data( 'Thickness', $s['t'] . ' mm' );
		}
		if ( ! empty( $values['fcnc_prep'] ) ) {
			$p = $values['fcnc_prep'];
			$order_item->add_meta_data( 'Finish', $p['finish'] );
			$order_item->add_meta_data( 'Hinge holes', $p['holes'] );
			if ( 'None' !== $p['holes'] ) {
				$order_item->add_meta_data( 'Hole positions', $p['positions'] );
				$order_item->add_meta_data( 'Hinge side', $p['side'] );
			}
			if ( $p['hinges'] > 0 ) {
				$order_item->add_meta_data( 'Soft-close hinges', $p['hinges'] );
			}
			if ( '' !== $p['notes'] ) {
				$order_item->add_meta_data( 'CNC notes', $p['notes'] );
			}
			if ( $p['extra_cost'] > 0 ) {
				$order_item->add_meta_data( '_fcnc_prep_cost', $p['extra_cost'] );
			}
		}
	}

	public function from_price_html( $html, $product ) {
		if ( $this->size_data( $product->get_id() ) ) {
			$min = (float) $product->get_regular_price( 'edit' );
			if ( $min > 0 ) {
				return 'From ' . wc_price( $min );
			}
		}
		return $html;
	}
}

new FastCNC_Custom_Size();
