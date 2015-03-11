<shader id="haxor/unlit/FlatReflect">	
		<vertex precision="medium">
		
		uniform mat4  WorldMatrix;
		uniform mat4  ViewMatrix;
		uniform mat4  ProjectionMatrix;
		uniform vec3  WSCameraPosition;
		
		uniform vec4 Tint;
		
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
			v_color = color * Tint;	
			v_normal = normal * mat3(WorldMatrix);
			v_wsView = v_wsVertex.xyz - WSCameraPosition;
			gl_Position = ((v_wsVertex) * ViewMatrix) * ProjectionMatrix;	
		}	
		</vertex>
		
		<fragment precision="medium">
			
			uniform vec3  Ambient;		
			uniform float  Time;					
			uniform samplerCube SkyboxTexture;
			
			uniform vec4 SkyboxColor;
			
			varying vec3 v_uv0;
			varying vec4 v_color;
			varying vec3 v_normal;
			varying vec4 v_wsVertex;
			varying vec3 v_wsView;
			
			
			void main(void) 
			{	
				vec3 n 			 	= normalize(v_normal);				
				vec3 view_dir 	 	= normalize(v_wsView);				
				vec4 tex_reflection = textureCube(SkyboxTexture,reflect(view_dir,n)) * SkyboxColor;
				
				gl_FragColor.xyz = v_color.xyz + tex_reflection.xyz;
				gl_FragColor.a   = v_color.a + tex_reflection.a;
			}
			
		</fragment>	
</shader>