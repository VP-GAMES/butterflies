shader_type spatial;

uniform sampler2D butterfly_tex;

uniform float displ_amnt = 1.0;
uniform float displ_speed = 10.0;
uniform float time_scale = 10.0;

void vertex()
{
	float mask = 1.0 - sin(PI * UV.x);
	float rand_val = COLOR.x * 10.0;
	
	float time = (TIME * time_scale) + (6.28318 * INSTANCE_CUSTOM.x);
	
	VERTEX.y += sin(rand_val + TIME * displ_speed) * displ_amnt * mask;
}

void fragment()
{
	vec4 col = texture(butterfly_tex, UV);
	ALPHA_SCISSOR_THRESHOLD = 0.01;
	ALPHA = col.a;
	ALBEDO = col.rgb;
}