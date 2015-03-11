<shader id="haxor/screen/Displacement">	

		<vertex precision="high">
		
		
		
		uniform mat4  WorldMatrix;
		uniform mat4  ViewMatrix;
		uniform mat4  ProjectionMatrix;		
		
		
		
		attribute vec3 vertex;					
		attribute vec4 color;
		attribute vec3 uv0;
		
		varying vec3 v_uv0;
		varying vec4 v_spos;
		varying vec4 v_color;
		
		void main(void) 
		{		
			vec4 hpos   = ((vec4(vertex, 1.0) * WorldMatrix) * ViewMatrix) * ProjectionMatrix;
			gl_Position = hpos;						
			//hpos.y        = -hpos.y;
			v_spos        = hpos;
			//v_spos      = (hpos.xyz+1.0)/2.0;
			v_uv0   	= uv0;
			v_color 	= color;
		}		
		</vertex>
		
		<fragment precision="high">
			
			uniform vec2  Offset;
			
			uniform vec2  Scale;
			
			uniform float Intensity;
			
			uniform sampler2D ScreenTexture;
			
			uniform sampler2D Texture;
			
			varying vec3 v_uv0;
			varying vec4 v_spos;
			varying vec4 v_color;
			
			
			void main(void) 
			{					
				float a			  = texture2D(Texture, v_uv0.xy).z;
				vec3 d		      = texture2D(Texture, (v_uv0.xy * Scale) + Offset).xyz;
				d = (d-0.5)*2.0;
				
				vec4 stc = ((v_spos / v_spos.w)+1.0)*0.5;								
				
				vec4 c = texture2D(ScreenTexture, stc.xy + (d.xy * Intensity * 0.1 * a));
				
				
				
				gl_FragColor.xyz = c.xyz * v_color.xyz;
				gl_FragColor.a 	 = c.a * v_color.a;
			}
		</fragment>	
	</shader>