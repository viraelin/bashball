shader_type canvas_item;

uniform float pixel = 0.0001;

void fragment() {
	vec2 uv = SCREEN_UV;
	uv = floor(uv / pixel + 0.5) * pixel;
	vec4 color = texture(SCREEN_TEXTURE, uv);
	
	float amount = pixel * 0.25;
	
	vec2 uv_r = uv;
	vec2 uv_g = uv;
	vec2 uv_b = uv;
	
	uv_r.x -= amount;
	uv_b.x += amount;
	
	float r = texture(SCREEN_TEXTURE, uv_r).r;
	float g = texture(SCREEN_TEXTURE, uv_g).g;
	float b = texture(SCREEN_TEXTURE, uv_b).b;
	
	color.r = r;
	color.g = g;
	color.b = b;
	
	// grayscale
//	float average = (color.r + color.g + color.b) / 3.0;
//	color.rgb = vec3(average);
	
	COLOR = color;
}