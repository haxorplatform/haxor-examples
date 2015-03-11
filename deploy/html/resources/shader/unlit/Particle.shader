<shader id="haxor/unlit/Particle">	

		<vertex precision="medium">
		
		#define IsLocal				 (System[1].z > 0.0)
		#define SheetFrameWidth	 	 System[21].x
		#define SheetFrameHeight 	 System[21].y
		#define SheetLength		 	 System[22].x
		#define SystemEmissionStart	 System[24].x
		#define SystemEmissionCount	 System[24].y
		
		#define PARTICLE_LENGTH		 7.0
		
		#define PARTICLE_STATUS		 0.0
		#define PARTICLE_POSITION	 1.0
		#define PARTICLE_ROTATION	 2.0
		#define PARTICLE_SIZE		 3.0
		#define PARTICLE_VELOCITY	 4.0
		#define PARTICLE_COLOR		 5.0
		#define PARTICLE_START		 6.0
		
		#define PARTICLE_DISABLED	 0
		#define PARTICLE_INIT		 1
		#define PARTICLE_ENABLED	 2
		#define PARTICLE_DEAD		 3
		
		attribute vec3 vertex;
				
		
		uniform mat4  WorldMatrix;
		uniform mat4  ViewMatrix;
		uniform mat4  ViewMatrixInverse;
		uniform mat4  ProjectionMatrix;		
		
		uniform float Time;
		
		uniform sampler2D Data;
		
		uniform float DataWidth;
		uniform float DataHeight;
		
		
		uniform float TextureWidth;
		uniform float TextureHeight;
		
		uniform vec4  System[25];
				
		
		varying vec2 v_uv0;
		varying vec4 v_color;
		
		
		uniform float RandomSeed;		
		uniform sampler2D RandomTexture;
		
		vec4 Random()
			{
				float tw   = 0.001953125;
				float seed = RandomSeed * 262144.0;
				float idx  = mod(seed,512.0) * tw;
				float idy  = floor(seed * tw)  * tw;
				seed      += tw;
				return texture2D(RandomTexture, vec2(idx,idy));
			}
		//*/
		vec4 ParticleData(float p_id,float p_field)
		{
			float w   = floor(DataWidth);
			float h   = floor(DataHeight);
			float pid = mod(floor(SystemEmissionStart)+p_id,floor(w*h)/PARTICLE_LENGTH);
			float pix = floor(pid) * PARTICLE_LENGTH;			
			float px  = mod(pix+p_field,w) / (w-1.0);
			float py  = floor((pix+p_field)/w) / (h-1.0);
			return texture2D(Data,vec2(px,py));
		}
		
		vec4 ParticleStatus()   { return ParticleData(vertex.z,PARTICLE_STATUS); 	}
		vec4 ParticlePosition() { return ParticleData(vertex.z,PARTICLE_POSITION); 	}
		vec4 ParticleRotation() { return ParticleData(vertex.z,PARTICLE_ROTATION); 	}
		vec4 ParticleSize() 	{ return ParticleData(vertex.z,PARTICLE_SIZE); 		}
		vec4 ParticleColor() 	{ return ParticleData(vertex.z,PARTICLE_COLOR); 		}
		
		void main(void) 
		{		
			
			vec4  status   = ParticleStatus();
			
			float enabled  = int(status.x) == PARTICLE_DEAD ? 0.0 : 1.0;
			
			vec4  v   = vec4(vertex.xy,0.0,1.0);
			v.xyz	 *= enabled;
			
			if(enabled <= 0.0) { gl_Position = vec4(0,0,0,-1.0); return; }
			
			vec3 size	   = ParticleSize().xyz;			
			vec3 center    = vec3(0,0,0);
			vec3 position  = ParticlePosition().xyz;
						
			v.xyz  *= size;
			v.xyz   = v.xyz * mat3(ViewMatrixInverse); //billboard
			
			v.xyz  += center + position;
			
			mat4 wm     = IsLocal ? WorldMatrix : mat4(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1); 
			
			gl_Position = ((v * wm) * ViewMatrix) * ProjectionMatrix;
			
			float frame   = floor(status.w);		
			
			v_uv0 = (vertex.xy+0.5);
			
			if(SheetLength > 0.0)
			{			
				float sw	  = (SheetFrameWidth);
				float sh	  = (SheetFrameHeight);			
				float tw	  = floor(TextureWidth);
				float th	  = floor(TextureHeight);
				float sheet_uvw = sw/tw;
				float sheet_uvh = sh/th;
				v_uv0   	*= vec2(sheet_uvw,sheet_uvh);					
				float cx     = floor(TextureWidth/SheetFrameWidth);
				v_uv0.x		 += (mod(frame,cx) * (sheet_uvw));
				v_uv0.y		 += 1.0 - (sheet_uvh) - (floor(frame/cx) * (sheet_uvh));
			}			
			
			v_color = ParticleColor();
		}		
		</vertex>
		
		<fragment precision="medium">
			
			
			varying vec2 v_uv0;
			varying vec4 v_color;
			
			uniform sampler2D Color;
			
			uniform sampler2D Texture;
			
			void main(void) 
			{	
				vec4 tex		 = texture2D(Texture, v_uv0.xy);
				gl_FragColor.xyz = tex.xyz * v_color.xyz;
				gl_FragColor.a 	 = tex.a * v_color.a;
			}
		</fragment>	
	</shader>