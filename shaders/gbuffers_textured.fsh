#version 120

#define TextureSize 16 //Resolution of texture pack [16 32 64 128 256 512 1024]
#define Changes 1 //Number of changes per day cycle [1 2 6 30 80 240 2400]

uniform sampler2D texture;
uniform sampler2D lightmap;

uniform vec4 entityColor;
uniform float blindness;
uniform int worldTime;
uniform int worldDay;
uniform int isEyeInWater;
uniform ivec2 atlasSize;

varying vec4 color;
varying vec3 world;
varying vec2 coord0;
varying vec2 coord1;

vec2 hash(vec3 p)
{
    return fract(cos(p.x*vec2(67.72,-93.51)+p.y*vec2(85.42,-91.08)+p.z*vec2(-80.25,71.39))*591.5)*492.4;
}
void main()
{
    vec3 light = (1.-blindness) * texture2D(lightmap,coord1).rgb;
    vec4 a = texture2D(texture,coord0);
    vec2 size = max(vec2(atlasSize/TextureSize),8.);
    float fix = float(atlasSize.x==0);

    vec4 col = vec4(0);
    int s = Changes*worldDay+Changes*worldTime/24000;
    vec2 t = hash(floor(world+(vec3(coord0*size,s)-world)*fix)+float(s));
    vec2 c = fract(coord0+floor(t)/size/(1.+3.*fix));
    c += .5*step(.5,c)*step(fract(t),vec2(.9,.5))*(1.-fix);

    vec4 b = texture2D(texture,c);
    col = vec4(b.rgb+(mix(a,b,b.a)-b).rgb*fix,a.a);
    col *= color * vec4(light,1);

    col.rgb = mix(col.rgb,entityColor.rgb,entityColor.a);

    float fog = (isEyeInWater>0) ? 1.-exp(-gl_FogFragCoord * gl_Fog.density):
    clamp((gl_FogFragCoord-gl_Fog.start) * gl_Fog.scale, 0., 1.);

    col.rgb = mix(col.rgb, gl_Fog.color.rgb, fog);

    gl_FragData[0] = col;
}
