<shader id="haxor/unlit/Float">	
		<vertex precision="medium">
		
		
		
		uniform mat4  WorldMatrix;
		uniform mat4  ViewMatrix;
		uniform mat4  ProjectionMatrix;		
		
		attribute vec3 vertex;					
		attribute vec4 color;
		attribute vec3 uv0;
		
		varying vec3 v_uv0;
		varying vec4 v_color;
		
		void main(void) 
		{		
			gl_Position = ((vec4(vertex, 1.0) * WorldMatrix) * ViewMatrix) * ProjectionMatrix;	
			v_uv0   = uv0;
			v_color = color;
		}		
		</vertex>
		
		<fragment precision="medium">
			
			
			varying vec3 v_uv0;
			varying vec4 v_color;
			
			uniform sampler2D DiffuseTexture;
			
			void main(void) 
			{	
				vec4 tex_diffuse = texture2D(DiffuseTexture, v_uv0.xy);
				
				gl_FragColor.xyz = tex_diffuse.xyz * 0.1;
				gl_FragColor.a 	 = tex_diffuse.a *0.1;
			}
		</fragment>	
	</shader>