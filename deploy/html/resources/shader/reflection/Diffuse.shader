<shader id="haxor/reflection/Diffuse">	
		<vertex precision="medium">
		
		uniform mat4  WorldMatrix;
		uniform mat4  ViewMatrix;
		uniform mat4  ProjectionMatrix;
		uniform vec3  WSCameraPosition;
		
		
		
		attribute vec3 vertex;					
		attribute vec4 color;
		attribute vec3 normal;
		attribute vec3 uv0;
		
		varying vec3 v_uv0;
		varying vec3 v_normal;
		varying vec4 v_color;
		varying vec4 v_wsVertex;
		varying vec3 v_wsView;	
		
		void main(void) 
		{		
			v_wsVertex =vec4(vertex, 1.0) * WorldMatrix;			
			v_uv0   = uv0;
			v_color = color;	
			v_normal = normal;
			v_wsView = v_wsVertex.xyz - WSCameraPosition;
			gl_Position = ((v_wsVertex) * ViewMatrix) * ProjectionMatrix;	
		}		
		</vertex>
		
		<fragment precision="medium">
			
			uniform vec3  Ambient;		
			uniform float  Time;		
			uniform sampler2D DiffuseTexture;
			uniform samplerCube SkyboxTexture;
			
			varying vec3 v_uv0;
			varying vec4 v_color;
			varying vec3 v_normal;
			varying vec4 v_wsVertex;
			varying vec3 v_wsView;
			
			
			void main(void) 
			{					
				vec4 tex_diffuse = texture2D(DiffuseTexture, v_uv0.xy);				
				vec3 n = normalize(v_normal);				
				vec3 view_dir = normalize(v_wsView);
				
				vec3 tex_reflection = textureCube(SkyboxTexture,reflect(view_dir,n)).xyz;
				
				vec3 light_pos = vec3(100,100,-100);
				vec3 light_dir = normalize(light_pos - v_wsVertex.xyz);
				
				
				float light_diffuse = clamp(dot(n,light_dir),0.0,1.0);
				
				gl_FragColor.xyz = (tex_reflection *1.0);// + (Ambient*tex_diffuse.xyz) + tex_diffuse.xyz * v_color.xyz * light_diffuse;
				gl_FragColor.a = tex_diffuse.a * v_color.a;
			}
		</fragment>	
	</shader>