
adore.shaders = {
		scanlines = love.graphics.newShader([[
			
			extern float fGlobalTime;
			
			float rand(vec2 co){
				return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
			}
			
			vec4 effect(vec4 color, Image tex, vec2 uv, vec2 pos)
			{
				
				vec4 c = color * texture2D(tex, uv);
				
				c.a = c.a * (sin(uv.y * 200 + fGlobalTime * 10) / 4 + 0.5);
				
				c.a = c.a * (rand(uv * fGlobalTime) + 0.8);
				
				return c;
			
			}
			]]),
		gaussian = love.graphics.newShader([[
			#ifdef GL_ES
				precision mediump float;
			#endif

			float normpdf(in float x, in float sigma)
			{
				return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
			}


			vec4 effect(vec4 color, Image tex, vec2 uv, vec2 pos)
			{
				vec3 c = texture2D(tex, uv).rgb;
					
					//declare stuff
					const int mSize = 11;
					const int kSize = (mSize-1)/2;
					float kernel[mSize];
					vec3 final_colour = vec3(0.0);
					
					//create the 1-D kernel
					float sigma = 7.0;
					float Z = 0.0;
					for (int j = 0; j <= kSize; ++j)
					{
						kernel[kSize+j] = kernel[kSize-j] = normpdf(float(j), sigma);
					}
					
					//get the normalization factor (as the gaussian has been clamped)
					for (int j = 0; j < mSize; ++j)
					{
						Z += kernel[j];
					}
					
					//read out the texels
					for (int i=-kSize; i <= kSize; ++i)
					{
						for (int j=-kSize; j <= kSize; ++j)
						{
							final_colour += kernel[kSize+j]*kernel[kSize+i]*texture2D(tex, uv.xy+vec2(float(i) / 1920.0,float(j) / 1080.0)).rgb;
				
						}
					}
					
					
					return vec4(final_colour/(Z*Z), 1.0) * color;
				
			}
			]]),
		crt = love.graphics.newShader([[
			
			extern float iGlobalTime;
			
			vec2 curve(vec2 uv)
			{
				uv = (uv - 0.5) * 2.0;
				uv *= 1.1;	
				uv.x *= 1.0 + pow((abs(uv.y) / 5.0), 2.0);
				uv.y *= 1.0 + pow((abs(uv.x) / 4.0), 2.0);
				uv  = (uv / 2.0) + 0.5;
				uv =  uv *0.92 + 0.04;
				return uv;
			}
			
			vec4 effect(vec4 color, Image tex, vec2 fragCoord, vec2 pos)
			{
				vec2 q = fragCoord.xy;
				vec2 uv = q;
				uv = curve( uv );
				vec3 oricol = texture2D( tex, vec2(q.x,q.y)).xyz;
				vec3 col;
				float x =  sin(0.3*iGlobalTime+uv.y*21.0)*sin(0.7*iGlobalTime+uv.y*29.0)*sin(0.3+0.33*iGlobalTime+uv.y*31.0)*0.0017;

				col.r = texture2D(tex,vec2(x+uv.x+0.001,uv.y+0.001)).x+0.05;
				col.g = texture2D(tex,vec2(x+uv.x+0.000,uv.y-0.002)).y+0.05;
				col.b = texture2D(tex,vec2(x+uv.x-0.002,uv.y+0.000)).z+0.05;
				col.r += 0.08*texture2D(tex,0.75*vec2(x+0.025, -0.027)+vec2(uv.x+0.001,uv.y+0.001)).x;
				col.g += 0.05*texture2D(tex,0.75*vec2(x+-0.022, -0.02)+vec2(uv.x+0.000,uv.y-0.002)).y;
				col.b += 0.08*texture2D(tex,0.75*vec2(x+-0.02, -0.018)+vec2(uv.x-0.002,uv.y+0.000)).z;

				col = clamp(col*0.6+0.4*col*col*1.0,0.0,1.0);

				float vig = (0.0 + 1.0*16.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y));
				col *= vec3(pow(vig,0.3));

				col *= vec3(0.95,1.05,0.95);
				col *= 2.8;

				float scans = clamp( 0.35+0.35*sin(3.5*iGlobalTime+uv.y*1080*1.5), 0.0, 1.0);
				
				float s = pow(scans,1.7);
				col = col*vec3( 0.4+0.7*s) ;

				col *= 1.0+0.01*sin(110.0*iGlobalTime);
				if (uv.x < 0.0 || uv.x > 1.0)
					col *= 0.0;
				if (uv.y < 0.0 || uv.y > 1.0)
					col *= 0.0;
				
				col*=1.0-0.65*vec3(clamp((mod(fragCoord.x, 2.0)-1.0)*2.0,0.0,1.0));
				
				float comp = smoothstep( 0.1, 0.9, sin(iGlobalTime) );
			 
				// Remove the next line to stop cross-fade between original and postprocess
			//	col = mix( col, oricol, comp );

				return vec4(col,1.0);
			}
			]]),
		
		lighting = love.graphics.newShader([[
			
			extern vec3 Light;
			extern Image NormalMap;
			extern float LightRadius;
			extern vec3 LightColor;
			extern float LightPower;
			extern vec2 CameraPos;
			extern vec3 PlayerPos;
			//extern vec2 PlayerSize;
			
			vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 pos) {
				vec2 screenPos = pos + CameraPos;
				vec3 poss = vec3(pos, 0);
				vec4 nrml = (2.0 * texture2D(NormalMap, tex_coords)) - 1.0;
				nrml.y = -nrml.y;
				float z = nrml.z;
				nrml.z = nrml.y;
				nrml.y = z;
				vec3 dir = Light - vec3(screenPos.x, PlayerPos.y, screenPos.y - (1080 - PlayerPos.y));
				float atten;
				atten = clamp(1.0 - length(dir)/LightRadius,0.0,1.0);// * abs(normalize(dir).r);
				//if (dir.z < 10) {
				//	atten = clamp(1.0 - length(dir)/LightRadius,0.0,1.0);
				//}
				//else {
				//	atten = clamp(1.0 - length(dir)/LightRadius,0.0,1.0) * clamp(0.4 - (nrml.a / 2.0 + 0.5),0.0,1.0) * 8.0;
				//}
				//return texture2D(tex, tex_coords) * dot(vec3(nrml.r, nrml.g, nrml.b), normalize(dir)) * vec4(LightColor,1.0) * atten * LightPower;
				
				return dot(vec3(nrml.r, nrml.g, nrml.b), normalize(dir)) * vec4(LightColor,texture2D(tex, tex_coords).a) * atten * LightPower;
				
			}
			
			]]),
		blur = love.graphics.newShader([[
	
			#define SAMPLE_COUNT 15

			extern vec2 SampleOffsets[SAMPLE_COUNT];
			extern float SampleWeights[SAMPLE_COUNT];
			
			vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 pos) {
				vec4 c = vec4(0,0,0,0);
				
				// Combine a number of weighted image filter taps.
				for (int i = 0; i < SAMPLE_COUNT; i++)
				{
						c += texture2D(tex, tex_coords + SampleOffsets[i]) * SampleWeights[i];
				}
				
				return c;
			}
		]]),
		glitch = love.graphics.newShader([[
			
			extern float fGlobalTime;
			extern float fAmount;
			
			float sat( float t ) {
				return clamp( t, 0.0, 1.0 );
			}

			vec2 sat( vec2 t ) {
				return clamp( t, 0.0, 1.0 );
			}

			//remaps inteval [a;b] to [0;1]
			float remap  ( float t, float a, float b ) {
				return sat( (t - a) / (b - a) );
			}

			//note: /\ t=[0;0.5;1], y=[0;1;0]
			float linterp( float t ) {
				return sat( 1.0 - abs( 2.0*t - 1.0 ) );
			}

			vec3 spectrum_offset( float t ) {
				vec3 ret;
				float lo = step(t,0.5);
				float hi = 1.0-lo;
				float w = linterp( remap( t, 1.0/6.0, 5.0/6.0 ) );
				float neg_w = 1.0-w;
				ret = vec3(lo,1.0,hi) * vec3(neg_w, w, neg_w);
				return pow( ret, vec3(1.0/2.2) );
			}

			//note: [0;1]
			float rand( vec2 n ) {
			  return fract(sin(dot(n.xy, vec2(12.9898, 78.233)))* 43758.5453);
			}

			//note: [-1;1]
			float srand( vec2 n ) {
				return rand(n) * 2.0 - 1.0;
			}

			float trunc( float x, float num_levels )
			{
				return floor(x*num_levels) / num_levels;
			}
			vec2 trunc( vec2 x, float num_levels )
			{
				return floor(x*num_levels) / num_levels;
			}

			vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 pos) 
			{
				vec2 uv = tex_coords;
				
				float time = mod(fGlobalTime, 32.0); // + modelmat[0].x + modelmat[0].z;

				float GLITCH = fAmount;
				
				float gnm = sat( GLITCH );
				float rnd0 = rand( trunc( vec2(time), 6.0 ) );
				float r0 = sat((1.0-gnm)*0.7 + rnd0);
				float rnd1 = rand( vec2(trunc( uv.x, 10.0*r0 ), time) ); //horz
				//float r1 = 1.0f - sat( (1.0f-gnm)*0.5f + rnd1 );
				float r1 = 0.5 - 0.5 * gnm + rnd1;
				r1 = 1.0 - max( 0.0, ((r1<1.0) ? r1 : 0.9999999) ); //note: weird ass bug on old drivers
				float rnd2 = rand( vec2(trunc( uv.y, 40.0*r1 ), time) ); //vert
				float r2 = sat( rnd2 );

				float rnd3 = rand( vec2(trunc( uv.y, 10.0*r0 ), time) );
				float r3 = (1.0-sat(rnd3+0.8)) - 0.1;

				float pxrnd = rand( uv + time );

				float ofs = 0.05 * r2 * GLITCH * ( rnd0 > 0.5 ? 1.0 : -1.0 );
				ofs += 0.5 * pxrnd * ofs;

				uv.y += 0.1 * r3 * GLITCH;

				vec4 sum = vec4(0.0);
				vec3 wsum = vec3(0.0);
				for( int i=0; i<10; ++i )
				{
					float t = float(i) / 10.0;
					uv.x = sat( uv.x + ofs * t );
					vec4 samplecol = texture2D(tex, uv );
					vec3 s = spectrum_offset( t );
					samplecol.rgb = samplecol.rgb * s;
					sum += samplecol;
					wsum += s;
				}
				sum.rgb /= wsum;
				sum.a /= 10.0;

				return sum;
			}
			
		]])
			
	}