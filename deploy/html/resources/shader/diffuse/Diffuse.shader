<shader id="haxor/diffuse/Diffuse">	
		
		<vertex precision="medium">
		
		
		
		uniform mat4  WorldMatrix;
		uniform mat4  ViewMatrix;
		uniform mat4  ProjectionMatrix;		
		
		uniform vec4 Tint;
		
		attribute vec3 vertex;					
		attribute vec4 color;
		attribute vec3 normal;
		attribute vec3 uv0;
		
		varying vec3 v_uv0;
		varying vec3 v_normal;
		varying vec4 v_color;
		varying vec4 v_wsVertex;
		
		void main(void) 
		{		
			v_wsVertex =vec4(vertex, 1.0) * WorldMatrix;
			v_uv0   = uv0;
			v_color = color * Tint;
			v_normal = normal * mat3(WorldMatrix);
			gl_Position = ((v_wsVertex) * ViewMatrix) * ProjectionMatrix;	
		}		
		</vertex>
		
		<fragment precision="medium">
			
			#define MAX_LIGHTS 4
		
			uniform vec4 Lights[MAX_LIGHTS*3];
			//attribs
			//position
			//color			
			
			uniform vec4  Ambient;		
			uniform sampler2D DiffuseTexture;
			
			varying vec3 v_uv0;
			varying vec4 v_color;
			varying vec3 v_normal;
			varying vec4 v_wsVertex;
			
			vec4 LightAttrib(int p_id)   
			{ 
				if(p_id==0) return Lights[0];
				if(p_id==1) return Lights[3];
				if(p_id==2) return Lights[6];
				if(p_id==3) return Lights[9];
				return vec4(-1,0,0,0);
			}
			
			vec3 LightPosition(int p_id)   
			{ 
				if(p_id==0) return Lights[0+1].xyz;
				if(p_id==1) return Lights[3+1].xyz;
				if(p_id==2) return Lights[6+1].xyz;
				if(p_id==3) return Lights[9+1].xyz;
				return vec3(0,0,0);
			}
			
			vec4 LightColor(int p_id)   
			{ 
				if(p_id==0) return Lights[0+2];
				if(p_id==1) return Lights[3+2];
				if(p_id==2) return Lights[6+2];
				if(p_id==3) return Lights[9+2];
				return vec4(0,0,0,1);
			}
			
			vec3 LightingDiffuse(float p_intensity,vec3 p_vector,vec4 p_color,vec3 p_normal, vec4 p_diffuse)
			{				
				float d = clamp(dot(p_normal,p_vector),0.0,1.0);
				vec3  c = p_diffuse.xyz * p_color.xyz * d * p_intensity;
				return c;
			}
			
			void main(void) 
			{	
				vec4 tex_diffuse = texture2D(DiffuseTexture, v_uv0.xy);
				vec3 n = normalize(v_normal);
				vec3 c = Ambient.xyz*tex_diffuse.xyz * v_color.xyz;
				int found =0;
				for(int i=0;i<MAX_LIGHTS;i++)
				{
					vec4 la 	= LightAttrib(i);
					vec3 lp 	= LightPosition(i);
					vec4 lc 	= LightColor(i);
					int t   	= int(la.x); //type
					float m		= la.y; 	 //intensity
					float r 	= la.z*0.5;	 //radius
					float atten = la.w; 	 //attenuation
					if(t>=0)
					{
						vec3 v   = -(v_wsVertex.xyz - lp);
						float a  = t == 0 ? (1.0 - clamp(length(v) / r, 0.0,1.0)) : 1.0;					
						vec3 dir = t == 0 ? normalize(v) : normalize(lp);						
						c += LightingDiffuse(m*a,dir,lc,n,tex_diffuse);
					}
					//*/
				}
				
				gl_FragColor.xyz = c;
				gl_FragColor.a = tex_diffuse.a * v_color.a;
			}
		</fragment>	
	</shader>