shader_type canvas_item;
render_mode unshaded;
uniform vec4 ambient : source_color = vec4(0.80,0.80,0.96,1.0);
uniform float exposure = 1.0;
uniform float saturation = 0.9;
uniform float warm_preserve = 0.9;
uniform float cloud_cover = 0.0;
varying vec4 item_modulate;
void vertex() { item_modulate = COLOR; }
bool inside_rect(vec2 p, vec4 r) { return all(greaterThanEqual(p,r.xy)) && all(lessThanEqual(p,r.zw)); }
float ellipse_mask(vec2 uv, vec2 center, vec2 radius) {
	return 1.0-smoothstep(0.70,1.0,length((uv-center)/radius));
}
void fragment() {
	vec4 texel=texture(TEXTURE,UV);
	vec3 color=texel.rgb;
	vec2 p = UV*vec2(1536.0,864.0);
	// Native pixel-font labels are drawn separately at these exact positions.
	if (p.y >= 348.0 && p.y <= 449.0 && p.x >= 482.0-(p.y-348.0)*0.0198 && p.x <= 544.0+(p.y-348.0)*0.0594) {
		color = vec3(0.102,0.121,0.18);
	}
	if (inside_rect(p,vec4(1275.0,428.0,1397.0,451.0)) || inside_rect(p,vec4(1275.0,466.0,1397.0,491.0)) || inside_rect(p,vec4(1275.0,505.0,1397.0,529.0))) {
		color = vec3(0.095,0.111,0.17);
	}
	float luma=dot(color,vec3(0.2126,0.7152,0.0722));
	vec3 graded=mix(vec3(luma),color,saturation)*ambient.rgb*exposure*(1.0-cloud_cover);
	float lit_zone=max(ellipse_mask(UV,vec2(0.308,0.338),vec2(0.153,0.168)),ellipse_mask(UV,vec2(0.044,0.344),vec2(0.040,0.083)));
	lit_zone=max(lit_zone,ellipse_mask(UV,vec2(0.457,0.271),vec2(0.027,0.065)));
	lit_zone=max(lit_zone,ellipse_mask(UV,vec2(0.726,0.104),vec2(0.029,0.074)));
	lit_zone=max(lit_zone,ellipse_mask(UV,vec2(0.946,0.317),vec2(0.025,0.068)));
	float amber=smoothstep(0.08,0.32,color.r-color.b)*smoothstep(0.25,0.66,color.r);
	COLOR=vec4(mix(graded,color*1.035,lit_zone*amber*warm_preserve),texel.a)*item_modulate;
}
