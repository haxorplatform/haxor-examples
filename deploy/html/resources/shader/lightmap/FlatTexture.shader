<shader id="haxor/lightmap/FlatTexture">	

		<vertex precision="low">
		
		
		
		uniform mat4  WorldMatrix;
		uniform mat4  ViewMatrix;
		uniform mat4  ProjectionMatrix;		
		
		



		attribute vec3 vertex;					
		attribute vec4 color;
		attribute vec3 uv0;
		attribute vec3 uv1;
		
		varying vec3 v_uv0;
		varying vec3 v_uv1;
		varying vec4 v_color;

		uniform vec4 Fog[2];
		uniform vec3 CameraProjection;
		varying float v_linear_depth;
		float LinearNF(float p_psz,float p_near,float p_far) { return p_near * (p_psz + 1.0) / (p_far + p_near - p_psz * (p_far - p_near)); }
		float LinearEye(float p_psz,float p_near,float p_far) { return (2.0 * p_near) / (p_far + p_near - p_psz * (p_far - p_near)); }
		float Depth2Eye(float p_psz,float p_near,float p_far) { return (2.0 * p_near * p_far) / (p_far + p_near - p_psz * (p_far- p_near)); }
		
		

		void main(void) 
		{		

			vec4 hpos = ((vec4(vertex, 1.0) * WorldMatrix) * ViewMatrix) * ProjectionMatrix;			
			gl_Position = hpos;

			v_linear_depth =  LinearNF(hpos.z/hpos.w,CameraProjection.x,CameraProjection.y);

			v_uv0   = uv0;
			v_uv1   = uv1;
			v_color = color;
		}		
		</vertex>
		
		<fragment precision="low">
			
			
			varying vec3 v_uv0;
			varying vec3 v_uv1;
			varying vec4 v_color;
			
			

			uniform sampler2D DiffuseTexture;
			
			uniform sampler2D Lightmap;
			
			uniform vec4 Fog[2];
			varying float v_linear_depth;



			void main(void) 
			{	

				float fog_factor = pow(clamp((v_linear_depth - Fog[1].z) / (Fog[1].w - Fog[1].z),0.0,1.0),Fog[1].y) * Fog[1].x;

				vec4 tex_diffuse  = texture2D(DiffuseTexture, v_uv0.xy);
				vec4 tex_lightmap = texture2D(Lightmap, v_uv1.xy);
				vec3 c			  = tex_diffuse.xyz * (tex_lightmap.w * 8.0) * tex_lightmap.xyz;
				
				gl_FragColor.xyz = mix(c.xyz * v_color.xyz, Fog[0].xyz,fog_factor);
				gl_FragColor.a 	 = tex_diffuse.a * v_color.a;
			}
		</fragment>	
	</shader>