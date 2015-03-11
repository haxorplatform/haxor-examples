<shader id="haxor/diffuse/Flat">	
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
			
			uniform vec4  Ambient;		
						
			varying vec3 v_uv0;
			varying vec4 v_color;
			varying vec3 v_normal;
			varying vec4 v_wsVertex;

			void main(void) 
			{	
				vec3 light_pos = vec3(100,100,-100);
				vec3 light_dir = normalize(light_pos - v_wsVertex.xyz);
				vec3 n = normalize(v_normal);
				float light_diffuse = clamp(dot(n,light_dir),0.0,1.0);
				gl_FragColor.xyz = Ambient.xyz + (v_color.xyz * light_diffuse);
				gl_FragColor.a = v_color.a;
			}
		</fragment>	
	</shader>