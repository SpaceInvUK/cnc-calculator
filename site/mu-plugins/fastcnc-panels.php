<?php
/**
 * Plugin Name: FAST CNC — Wall Panels (fixed-size configurator)
 * Description: Fixed-size wall-panel section. Shortcode [fastcnc_panels] renders style -> size -> thickness -> qty cards and adds to basket with a server-side price. Data lives in wp-content/uploads/fastcnc-panels.json (edit that file to update prices/sizes).
 * Version: 1.0.0
 * Author: FAST CNC
 */

defined( 'ABSPATH' ) || exit;

class FastCNC_Panels {

	const OPT_PID = 'fcnc_panel_product_id';
	private $data = null;

	public function __construct() {
		add_shortcode( 'fastcnc_panels', array( $this, 'shortcode' ) );
		add_filter( 'woocommerce_add_to_cart_validation', array( $this, 'validate_add_to_cart' ), 10, 6 );
		add_filter( 'woocommerce_add_cart_item_data', array( $this, 'capture' ), 10, 2 );
		add_action( 'woocommerce_before_calculate_totals', array( $this, 'apply_price' ), 20 );
		add_filter( 'woocommerce_get_item_data', array( $this, 'cart_display' ), 10, 2 );
		add_filter( 'woocommerce_cart_item_name', array( $this, 'cart_name' ), 10, 3 );
		add_action( 'woocommerce_checkout_create_order_line_item', array( $this, 'order_meta' ), 10, 3 );
		add_filter( 'woocommerce_product_is_visible', array( $this, 'hide_base_product' ), 10, 2 );
		add_action( 'template_redirect', array( $this, 'redirect_base_product' ) );
	}

	/* ---------- data ---------- */

	private function data() {
		if ( null !== $this->data ) {
			return $this->data;
		}
		$file = WP_CONTENT_DIR . '/uploads/fastcnc-panels.json';
		$this->data = is_readable( $file ) ? json_decode( file_get_contents( $file ), true ) : array( 'panels' => array() );
		if ( empty( $this->data['panels'] ) ) {
			$this->data = array( 'panels' => array() );
		}
		return $this->data;
	}

	private function panel( $id ) {
		foreach ( $this->data()['panels'] as $p ) {
			if ( $p['id'] === $id ) {
				return $p;
			}
		}
		return null;
	}

	/** Server-side price lookup (never trusts the client). */
	private function price( $id, $size, $th ) {
		$p = $this->panel( $id );
		if ( ! $p || ! isset( $p['finalFastCncPrices'][ $size ][ $th ] ) ) {
			return null;
		}
		return (float) $p['finalFastCncPrices'][ $size ][ $th ];
	}

	private function size_meta( $id, $size ) {
		$p = $this->panel( $id );
		if ( $p ) {
			foreach ( $p['availableSizes'] as $s ) {
				if ( $s['key'] === $size ) {
					return $s;
				}
			}
		}
		return null;
	}

	/* ---------- front-end shortcode ---------- */

	public function shortcode() {
		$pid = (int) get_option( self::OPT_PID, 0 );
		$panels = $this->data()['panels'];
		if ( ! $pid || empty( $panels ) ) {
			return '<p>Wall panel configurator is not set up yet.</p>';
		}
		$pat = array(
			'fluted'            => 'repeating-linear-gradient(90deg,#c9ccd4 0 3px,#eef0f4 3px 7px,#c9ccd4 7px 10px)',
			'ribbed'            => 'repeating-linear-gradient(90deg,#c4c8d1 0 5px,#f0f2f6 5px 11px,#c4c8d1 11px 16px)',
			'mini-rib'          => 'repeating-linear-gradient(90deg,#c9ccd4 0 2px,#eef0f4 2px 4px)',
			'beaded'            => 'repeating-linear-gradient(90deg,#eef0f4 0 10px,#c4c8d1 10px 11px,#aeb3bf 11px 12px,#c4c8d1 12px 13px)',
			'tongue-and-groove' => 'repeating-linear-gradient(90deg,#eef0f4 0 13px,#b7bcc8 13px 15px)',
			'traditional'       => 'repeating-linear-gradient(90deg,#eef0f4 0 16px,#aeb3bf 16px 17px,#eef0f4 17px 18px,#b7bcc8 18px 20px)',
			'shaker'            => 'linear-gradient(#eef0f4,#eef0f4) padding-box, #b7bcc8',
			'modern'            => 'repeating-linear-gradient(90deg,#c4c8d1 0 8px,#f4f6fa 8px 14px)',
			'v-groove'          => 'repeating-linear-gradient(90deg,#d7dae2 0 9px,#aeb3bf 9px 10px,#d7dae2 10px 19px,#8f95a3 19px 20px)',
			'grooved'           => 'repeating-linear-gradient(90deg,#d7dae2 0 14px,#9aa0ae 14px 16px)',
		);
		$boot = wp_json_encode( array( 'panels' => $panels, 'pat' => $pat ) );

		ob_start();
		?>
<div id="fcnc-panels-app" data-boot="<?php echo esc_attr( $boot ); ?>">
	<style><?php echo self::CSS; // phpcs:ignore ?></style>
	<div class="fp-h">Wall Panels</div>
	<p class="fp-sub">Choose a style, size and thickness — fixed-size paintable MDF panels, made to order.</p>

	<div class="fp-step"><b>1</b> Choose your panel style</div>
	<div class="fp-styles" id="fp-styles"><noscript>Please enable JavaScript to configure a panel.</noscript></div>

	<form class="fp-config" id="fp-config" method="post" action="">
		<input type="hidden" name="add-to-cart" value="<?php echo esc_attr( $pid ); ?>">
		<input type="hidden" name="quantity" id="fp-in-qty" value="1">
		<input type="hidden" name="fcnc_panel" id="fp-in-panel" value="">
		<input type="hidden" name="fcnc_size" id="fp-in-size" value="">
		<input type="hidden" name="fcnc_th" id="fp-in-th" value="">

		<div class="fp-step"><b>2</b> Choose your size</div>
		<div class="fp-sizes" id="fp-sizes"></div>

		<div class="fp-step"><b>3</b> Choose your thickness</div>
		<div class="fp-seg" id="fp-th"></div>

		<div class="fp-step"><b>4</b> Quantity</div>
		<div class="fp-qty"><button type="button" data-q="-1">&ndash;</button><input id="fp-qty" value="1" inputmode="numeric"><button type="button" data-q="1">+</button></div>

		<div class="fp-bar">
			<div class="fp-total">Total <b id="fp-total">&mdash;</b></div>
			<button type="submit" class="fp-add" id="fp-add" disabled>Add to basket</button>
		</div>
	</form>

	<div class="fp-bespoke">
		<span><strong>Need a bespoke panel size?</strong> These panels come in fixed sizes. For a custom size, contact Fast CNC for a quote.</span>
		<a class="fp-bespoke-link" href="mailto:info@fastcnc.co.uk?subject=Bespoke%20panel%20quote">Request bespoke panel quote</a>
	</div>

	<script><?php echo self::JS; // phpcs:ignore ?></script>
</div>
		<?php
		return ob_get_clean();
	}

	/* ---------- cart plumbing ---------- */

	private function request_configuration() {
		$id   = isset( $_REQUEST['fcnc_panel'] ) ? sanitize_key( wp_unslash( $_REQUEST['fcnc_panel'] ) ) : '';
		$size = isset( $_REQUEST['fcnc_size'] ) ? preg_replace( '/[^0-9x]/', '', wp_unslash( $_REQUEST['fcnc_size'] ) ) : '';
		$th   = isset( $_REQUEST['fcnc_th'] ) ? preg_replace( '/\D/', '', wp_unslash( $_REQUEST['fcnc_th'] ) ) : '';

		return array(
			'id'    => $id,
			'size'  => $size,
			'th'    => $th,
			'price' => $this->price( $id, $size, $th ),
		);
	}

	public function validate_add_to_cart( $passed, $product_id, $quantity, $variation_id = 0, $variations = array(), $cart_item_data = array() ) {
		if ( (int) $product_id !== (int) get_option( self::OPT_PID, 0 ) ) {
			return $passed;
		}

		$config = $this->request_configuration();
		if ( null !== $config['price'] ) {
			return $passed;
		}

		wc_add_notice( 'Please choose a valid wall panel style, size and thickness before adding it to your basket.', 'error' );
		return false;
	}

	public function capture( $cart_item_data, $product_id ) {
		if ( (int) $product_id !== (int) get_option( self::OPT_PID, 0 ) ) {
			return $cart_item_data;
		}
		$config = $this->request_configuration();
		if ( null === $config['price'] ) {
			return $cart_item_data;
		}
		$cart_item_data['fcnc_panel'] = array(
			'id'    => $config['id'],
			'size'  => $config['size'],
			'th'    => $config['th'],
			'price' => $config['price'],
		);
		return $cart_item_data;
	}

	public function hide_base_product( $visible, $product_id ) {
		if ( (int) $product_id === (int) get_option( self::OPT_PID, 0 ) ) {
			return false;
		}
		return $visible;
	}

	public function redirect_base_product() {
		if ( ! is_product() || (int) get_queried_object_id() !== (int) get_option( self::OPT_PID, 0 ) ) {
			return;
		}
		wp_safe_redirect( home_url( '/wall-panels-2/' ), 302 );
		exit;
	}

	public function apply_price( $cart ) {
		if ( is_admin() && ! defined( 'DOING_AJAX' ) ) {
			return;
		}
		foreach ( $cart->get_cart() as $item ) {
			if ( ! empty( $item['fcnc_panel']['price'] ) ) {
				$item['data']->set_price( (float) $item['fcnc_panel']['price'] );
			}
		}
	}

	public function cart_display( $item_data, $cart_item ) {
		if ( ! empty( $cart_item['fcnc_panel'] ) ) {
			$s = $cart_item['fcnc_panel'];
			$meta = $this->size_meta( $s['id'], $s['size'] );
			list( $w, $h ) = array_map( 'intval', explode( 'x', $s['size'] ) );
			$item_data[] = array( 'key' => 'Size', 'value' => $w . ' × ' . $h . ' mm' . ( $meta ? ' (' . $meta['note'] . ')' : '' ) );
			$item_data[] = array( 'key' => 'Thickness', 'value' => $s['th'] . ' mm' );
		}
		return $item_data;
	}

	public function cart_name( $name, $cart_item, $cart_item_key ) {
		if ( ! empty( $cart_item['fcnc_panel'] ) ) {
			$p = $this->panel( $cart_item['fcnc_panel']['id'] );
			if ( $p ) {
				return esc_html( $p['name'] ) . ' Wall Panel';
			}
		}
		return $name;
	}

	public function order_meta( $order_item, $cart_item_key, $values ) {
		if ( ! empty( $values['fcnc_panel'] ) ) {
			$s = $values['fcnc_panel'];
			$p = $this->panel( $s['id'] );
			list( $w, $h ) = array_map( 'intval', explode( 'x', $s['size'] ) );
			$order_item->add_meta_data( 'Style', $p ? $p['name'] : $s['id'] );
			$order_item->add_meta_data( 'Size', $w . ' × ' . $h . ' mm' );
			$order_item->add_meta_data( 'Thickness', $s['th'] . ' mm' );
		}
	}

	/* ---------- assets ---------- */

	const CSS = <<<'CSS'
#fcnc-panels-app{--ink:#1c2333;--muted:#6b7280;--line:#e4e7ee;--accent:#0f4c81;--accent2:#12a150;--card:#fff;font-family:system-ui,-apple-system,"Segoe UI",Roboto,sans-serif;color:var(--ink);max-width:1080px;margin:0 auto}
#fcnc-panels-app *{box-sizing:border-box}
#fcnc-panels-app .fp-h{font-size:1.7rem;font-weight:700;margin:.2em 0 .1em}
#fcnc-panels-app .fp-sub{color:var(--muted);margin:0 0 1.2em}
#fcnc-panels-app .fp-step{font-size:.78rem;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:var(--accent);margin:1.4em 0 .6em;display:flex;align-items:center;gap:.5em}
#fcnc-panels-app .fp-step b{background:var(--accent);color:#fff;width:1.5em;height:1.5em;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:.8em}
#fcnc-panels-app .fp-styles{display:grid;grid-template-columns:repeat(auto-fill,minmax(150px,1fr));gap:12px}
#fcnc-panels-app .fp-style{border:1.5px solid var(--line);border-radius:12px;overflow:hidden;cursor:pointer;background:var(--card);transition:.15s;text-align:left;padding:0;width:100%}
#fcnc-panels-app .fp-style:hover{border-color:var(--accent);transform:translateY(-2px);box-shadow:0 6px 18px rgba(15,76,129,.10)}
#fcnc-panels-app .fp-style.sel{border-color:var(--accent);box-shadow:0 0 0 2px var(--accent)}
#fcnc-panels-app .fp-thumb{height:92px;background-size:cover}
#fcnc-panels-app .fp-style .b{padding:9px 11px}
#fcnc-panels-app .fp-style .n{font-weight:650;font-size:.98rem}
#fcnc-panels-app .fp-style .p{color:var(--muted);font-size:.82rem;margin-top:2px}
#fcnc-panels-app .fp-config{margin-top:.4em;border-top:1px solid var(--line);padding-top:.4em;display:none}
#fcnc-panels-app .fp-config.on{display:block}
#fcnc-panels-app .fp-sizes{display:grid;grid-template-columns:repeat(auto-fill,minmax(165px,1fr));gap:10px}
#fcnc-panels-app .fp-size{border:1.5px solid var(--line);border-radius:11px;padding:12px 13px;cursor:pointer;background:var(--card);transition:.12s;text-align:left;width:100%}
#fcnc-panels-app .fp-size:hover{border-color:var(--accent)}
#fcnc-panels-app .fp-size.sel{border-color:var(--accent);background:#f2f7fc;box-shadow:0 0 0 1.5px var(--accent) inset}
#fcnc-panels-app .fp-size .dim{font-weight:700;font-size:1.02rem}
#fcnc-panels-app .fp-size .lab{color:var(--muted);font-size:.8rem;margin:2px 0 6px}
#fcnc-panels-app .fp-size .pr{font-weight:700;color:var(--accent)}
#fcnc-panels-app .fp-seg{display:inline-flex;border:1.5px solid var(--line);border-radius:10px;overflow:hidden}
#fcnc-panels-app .fp-seg button{border:0;background:var(--card);padding:10px 20px;font-size:1rem;font-weight:650;cursor:pointer;color:var(--ink);border-right:1.5px solid var(--line)}
#fcnc-panels-app .fp-seg button:last-child{border-right:0}
#fcnc-panels-app .fp-seg button.sel{background:var(--accent);color:#fff}
#fcnc-panels-app .fp-qty{display:inline-flex;align-items:center;border:1.5px solid var(--line);border-radius:10px;overflow:hidden}
#fcnc-panels-app .fp-qty button{border:0;background:var(--card);width:42px;height:44px;font-size:1.3rem;cursor:pointer;color:var(--ink)}
#fcnc-panels-app .fp-qty input{width:54px;height:44px;border:0;border-left:1.5px solid var(--line);border-right:1.5px solid var(--line);text-align:center;font-size:1.05rem;font-weight:650}
#fcnc-panels-app .fp-bar{display:flex;align-items:center;gap:18px;flex-wrap:wrap;margin-top:1.6em;padding:16px 18px;border:1.5px solid var(--line);border-radius:14px;background:#fafbfd}
#fcnc-panels-app .fp-total{font-size:1rem;color:var(--muted)}
#fcnc-panels-app .fp-total b{display:block;font-size:1.8rem;color:var(--ink);line-height:1.1}
#fcnc-panels-app .fp-add{margin-left:auto;background:var(--accent2);color:#fff;border:0;border-radius:11px;padding:15px 30px;font-size:1.05rem;font-weight:700;cursor:pointer}
#fcnc-panels-app .fp-add:disabled{background:#c3c7d0;cursor:not-allowed}
#fcnc-panels-app .fp-bespoke{margin-top:1.3em;padding:15px 18px;border:1.5px dashed var(--line);border-radius:12px;display:flex;align-items:center;gap:14px;flex-wrap:wrap;color:var(--muted)}
#fcnc-panels-app .fp-bespoke-link{margin-left:auto;background:transparent;border:1.5px solid var(--accent);color:var(--accent);border-radius:10px;padding:11px 20px;font-weight:650;text-decoration:none}
#fcnc-panels-app .fp-bespoke-link:hover{background:var(--accent);color:#fff}
CSS;

	const JS = <<<'JS'
(function(){
	var app=document.getElementById('fcnc-panels-app');
	var boot=JSON.parse(app.getAttribute('data-boot'));
	var DATA=boot.panels, PAT=boot.pat, FROM={};
	DATA.forEach(function(p){var m=1/0;Object.keys(p.finalFastCncPrices).forEach(function(k){Object.keys(p.finalFastCncPrices[k]).forEach(function(t){var v=p.finalFastCncPrices[k][t];if(v<m)m=v;});});FROM[p.id]=m;});
	var sel={panel:null,size:null,th:18,qty:1};
	var $=function(id){return document.getElementById(id);};
	function find(id){for(var i=0;i<DATA.length;i++){if(DATA[i].id===id)return DATA[i];}return null;}

	function renderStyles(){
		$('fp-styles').innerHTML=DATA.map(function(p){
			return '<button type="button" class="fp-style" data-id="'+p.id+'"><div class="fp-thumb" style="background:'+PAT[p.id]+'"></div><div class="b"><div class="n">'+p.name+'</div><div class="p">from £'+FROM[p.id]+'</div></div></button>';
		}).join('');
		Array.prototype.forEach.call($('fp-styles').querySelectorAll('.fp-style'),function(el){el.onclick=function(){pickPanel(el.dataset.id);};});
	}
	function pickPanel(id){
		sel.panel=id;sel.size=null;
		Array.prototype.forEach.call($('fp-styles').querySelectorAll('.fp-style'),function(e){e.classList.toggle('sel',e.dataset.id===id);});
		var p=find(id);
		if(p.thicknessOptions.indexOf(sel.th)<0)sel.th=p.defaultThickness||p.thicknessOptions[0];
		$('fp-th').innerHTML=p.thicknessOptions.map(function(t){return '<button type="button" data-t="'+t+'" class="'+(t===sel.th?'sel':'')+'">'+t+'mm</button>';}).join('');
		Array.prototype.forEach.call($('fp-th').querySelectorAll('button'),function(b){b.onclick=function(){sel.th=+b.dataset.t;renderSizes();renderTh();update();};});
		$('fp-config').classList.add('on');
		renderSizes();update();
		$('fp-config').scrollIntoView({behavior:'smooth',block:'nearest'});
	}
	function renderTh(){Array.prototype.forEach.call($('fp-th').querySelectorAll('button'),function(b){b.classList.toggle('sel',+b.dataset.t===sel.th);});}
	function renderSizes(){
		var p=find(sel.panel);
		$('fp-sizes').innerHTML=p.availableSizes.map(function(s){
			var pr=p.finalFastCncPrices[s.key][sel.th];
			return '<button type="button" class="fp-size '+(s.key===sel.size?'sel':'')+'" data-k="'+s.key+'"><div class="dim">'+s.w+' × '+s.h+' mm</div><div class="lab">'+s.note+'</div><div class="pr">£'+pr+'</div></button>';
		}).join('');
		Array.prototype.forEach.call($('fp-sizes').querySelectorAll('.fp-size'),function(el){el.onclick=function(){sel.size=el.dataset.k;renderSizes();update();};});
	}
	function update(){
		var p=find(sel.panel);
		if(!p||!sel.size){$('fp-total').textContent='—';$('fp-add').disabled=true;return;}
		var unit=p.finalFastCncPrices[sel.size][sel.th], tot=unit*sel.qty;
		$('fp-total').textContent='£'+tot+(sel.qty>1?' ('+sel.qty+' × £'+unit+')':'');
		$('fp-add').disabled=false;
		$('fp-in-panel').value=sel.panel;$('fp-in-size').value=sel.size;$('fp-in-th').value=sel.th;$('fp-in-qty').value=sel.qty;
	}
	Array.prototype.forEach.call(document.querySelectorAll('.fp-qty [data-q]'),function(b){b.onclick=function(){sel.qty=Math.max(1,sel.qty+(+b.dataset.q));$('fp-qty').value=sel.qty;update();};});
	$('fp-qty').oninput=function(e){sel.qty=Math.max(1,parseInt(e.target.value,10)||1);update();};
	$('fp-config').addEventListener('submit',function(e){if($('fp-add').disabled){e.preventDefault();}});
	renderStyles();
})();
JS;
}

new FastCNC_Panels();
