<shader id="haxor/kernel/ParticleKernel">	
		<vertex precision="high">
		
		attribute vec3 vertex;		
		
		varying vec2 iterator;
				
		void main(void) 
		{	
			gl_Position = vec4(vertex,1.0);
			iterator.x = (vertex.x+1.0)*0.5;
			iterator.y = (vertex.y+1.0)*0.5;
		}		
		</vertex>
		
		<fragment precision="high">
		
			#define EmmiterType			 int(System[0].x)
			#define EmitterSize			 System[0].yzw
			
			#define IsSurfaceEmission	 (System[1].x > 0.0)
			#define IsRandomDirection	 (System[1].y > 0.0)			
			#define IsLocal				 (System[1].z > 0.0)
			#define IsLoop				 (System[1].w > 0.0)
			
			#define SystemState			 int(System[2].x)
			#define SystemProgress		 System[2].y			
			#define DeltaTime		 	 System[2].w
			
			#define StartSpeed			 System[3]
			#define StartSize0			 System[4]
			#define StartSize1			 System[5]
			#define StartLife			 System[6]
			#define StartRotation0		 System[7]
			#define StartRotation1		 System[8]
			
			#define LifeSpeed			 System[9]
			#define LifeMotion0			 System[10]
			#define LifeMotion1			 System[11]
			#define LifeSize0			 System[12]
			#define LifeSize1			 System[13]
			#define LifeRotation0		 System[14]
			#define LifeRotation1		 System[15]
			
			#define SystemForce			 System[16].xyz
			
			#define WorldMatrix			 mat4(System[17].xyzw, System[18].xyzw, System[19].xyzw, vec4(0,0,0,1))
			
			#define StartFrame			 System[20]
			#define SheetFrameWidth	 	 System[21].x
			#define SheetFrameHeight 	 System[21].y
			#define SheetFPS		 	 System[21].z
			#define SheetWrap		 	 System[21].w
			#define SheetLength		 	 System[22].x
			#define EmitterRangeX	 	 System[22].yz
			#define EmitterRangeY	 	 System[23].xy
			#define EmitterRangeZ	 	 System[23].zw
			#define SystemEmissionStart	 System[24].x
			#define SystemEmissionCount	 System[24].y
						
			#define PARTICLE_LENGTH		 7.0
			
			#define EMITTER_SPHERE		 0
			#define EMITTER_BOX			 1
			#define EMITTER_CONE		 2
			#define EMITTER_CYLINDER	 3
			
			#define PARTICLE_STATUS		 0
			#define PARTICLE_POSITION	 1
			#define PARTICLE_ROTATION	 2
			#define PARTICLE_SIZE		 3
			#define PARTICLE_VELOCITY	 4
			#define PARTICLE_COLOR		 5
			#define PARTICLE_START		 6
			
			#define STATE_NONE		 0
			#define STATE_RESET		 1
			#define STATE_UPDATE	 2
			
			#define PARTICLE_DISABLED	 0
			#define PARTICLE_INIT		 1
			#define PARTICLE_ENABLED	 2
			#define PARTICLE_DEAD		 3
			
			float particle_id;			
			float particle_field;
			float fragment_id;
			
			varying vec2 iterator;
			
			uniform sampler2D Data;
			
			uniform sampler2D StartColor;
			
			uniform sampler2D Color;
			
			uniform float width;
			
			uniform float height;
			
			uniform vec4  System[25];
			
			uniform float 		RandomSeed;		
			uniform sampler2D 	RandomTexture;
			
			
			vec4 Random()
			{
				float tw   = 0.001953125;
				float seed = RandomSeed * 262144.0;
				float idx  = mod(seed+fragment_id,512.0) * tw;
				float idy  = floor((seed+fragment_id) * tw)  * tw;
				vec2  ruv  = vec2(idx,idy);
				seed      += tw * fract(sin(dot(ruv ,vec2(12.9898,78.233))) * 43758.5453);
				return texture2D(RandomTexture, ruv);
			}
			
			vec3 RandomVector()
			{
				return (Random().xyz - 0.5)*2.0;
			}
			
			float Lerp(float a, float b,float r) { return a + ((b-a)*r); }
			vec2  Lerp(vec2  a, vec2  b,float r) { return a + ((b-a)*r); }
			vec3  Lerp(vec3  a, vec3  b,float r) { return a + ((b-a)*r); }
			vec4  Lerp(vec4  a, vec4  b,float r) { return a + ((b-a)*r); }
			
			
			
			
			vec3 GetSphereRandomPosition(bool p_surface,float p_radius)	
			{	
				float r   = (p_radius*0.5);
				vec3 v    = RandomVector();								
				return p_surface ? (normalize(v) * r) : (v * r); 
			}
			
			vec3 GetBoxRandomPosition(bool p_surface,vec3 p_size)
			{				
				vec3 hs  = p_size*0.5;
				if(p_surface)
				{
					vec3 p = GetSphereRandomPosition(true,length(p_size));
					p.x = clamp(p.x,-hs.x,hs.x);
					p.y = clamp(p.y,-hs.y,hs.y);
					p.z = clamp(p.z,-hs.z,hs.z);
					return p;
				}			
				vec3 rnd = Random().xyz;
				return vec3( Lerp(-hs.x,hs.x,rnd.x), Lerp(-hs.y,hs.y,rnd.y), Lerp(-hs.z,hs.z,rnd.z));
			}
			
			vec3 GetEmitterRandomPosition()
			{
				int id 			= EmmiterType;
				bool is_surface = IsSurfaceEmission;
				
				if(id == EMITTER_SPHERE) return GetSphereRandomPosition(is_surface,EmitterSize.x);
				if(id == EMITTER_BOX) 	 return GetBoxRandomPosition(is_surface,EmitterSize);
				return GetSphereRandomPosition(is_surface,EmitterSize.x);
			}
						
			vec3 SampleParticleAttribVec3(vec4 p_start,vec4 p_end,float p_random)
			{
				float c  = p_start.w;
				float rf = p_end.w;				
				vec3 a   = p_start.xyz;
				vec3 b   = p_end.xyz;
				return (rf > 0.0) ? Lerp(a,b,p_random) : Lerp(a,b,pow(SystemProgress,c));
			}
			
			float SampleParticleAttribFloat(vec4 p_attribute,float p_random)
			{
				vec4 a   = p_attribute;				
				return (a.w > 0.0) ? Lerp(a.x,a.y,p_random) : Lerp(a.x,a.y,pow(SystemProgress,a.z));
			}
			
			vec4 ParticleData(float p_id,int p_field)
			{
				float pix = floor(p_id) * PARTICLE_LENGTH;
				float f   = float(p_field);
				float w   = floor(width);
				float h   = floor(height);
				float px  = mod(pix+f,w) / (w-1.0);
				float py  = floor((pix+f)/w) / (h-1.0);
				return texture2D(Data,vec2(px,py));
			}
		
			vec4 ParticleStatus()   	{ return ParticleData(particle_id,PARTICLE_STATUS); 	}
			vec4 ParticlePosition() 	{ return ParticleData(particle_id,PARTICLE_POSITION); 	}
			vec4 ParticleRotation() 	{ return ParticleData(particle_id,PARTICLE_ROTATION); 	}
			vec4 ParticleSize() 		{ return ParticleData(particle_id,PARTICLE_SIZE); 		}
			vec4 ParticleVelocity()		{ return ParticleData(particle_id,PARTICLE_VELOCITY);	}
			vec4 ParticleColor() 		{ return ParticleData(particle_id,PARTICLE_COLOR); 		}
			vec4 ParticleStart() 		{ return ParticleData(particle_id,PARTICLE_START); 		}
		
			
			vec4 UpdateStatus(int p_state,vec4 p_current)
			{
				//[state][life][duration][frame]
				vec4 p   = p_current;
				
				if(int(p.x) == PARTICLE_DISABLED)
				{
					vec4 rnd = Random();
					p.x = 1.0;
					p.y = 0.0;
					p.z = SampleParticleAttribFloat(StartLife,rnd.x);
					p.w = SampleParticleAttribFloat(StartFrame,rnd.y);
					return p;
				}
				
				if(int(p.x) == PARTICLE_INIT)
				{
					p.x = 2.0;
				}
				
				if(int(p.x) == PARTICLE_ENABLED)
				{						
					if(p.y >= p.z)
					{
						p.y = p.z;
						p.x = 3.0;
						return p;
					}
					p.y += DeltaTime;					
					p.w += SheetFPS * DeltaTime;
					if(p.w >= SheetLength)
					{
						p.w = SheetLength;						
						if(int(SheetWrap)==1) p.w=0.0;						
					}
					return p;
				}
				
				return p;
			}
			
			vec4 UpdatePosition(int p_state,vec4 p_status,vec4 p_current)
			{
				vec4 p   = p_status;
				vec4 c   = p_current;
				
				if(int(p.x) == PARTICLE_DISABLED)
				{
					c.xyz = GetEmitterRandomPosition();
					if(!IsLocal) { c.w=1.0; c = c * WorldMatrix; }
				}
				
				if(int(p.x) == PARTICLE_ENABLED)
				{
					float r = p.z <= 0.0 ? 0.0 : (p.y/p.z);
					vec3  v = ParticleVelocity().xyz * Lerp(LifeMotion0.xyz,LifeMotion1.xyz,r);					
					float speed =  Lerp(StartSpeed.x,StartSpeed.y,ParticleStart().x) * Lerp(LifeSpeed.x,LifeSpeed.y,r);					
					c.xyz += v * speed * DeltaTime;
				}
				
				return c;
			}
			
			
			vec4 UpdateVelocity(int p_state,vec4 p_status,vec4 p_current)
			{
				vec4 p   		= p_status;				
				vec4 c   		= p_current;
				
				if(int(p.x) == PARTICLE_INIT)
				{
					vec4 rnd;
					c.xyz  = IsRandomDirection ? normalize((Random().xyz-0.5)*2.0) : normalize(ParticlePosition().xyz);					
					c.x = clamp(c.x,EmitterRangeX.x,EmitterRangeX.y);
					c.y = clamp(c.y,EmitterRangeY.x,EmitterRangeY.y);
					c.z = clamp(c.z,EmitterRangeZ.x,EmitterRangeZ.y);
					c = normalize(c);
				}
				
				if(int(p.x) == PARTICLE_ENABLED)
				{
					c.xyz += SystemForce * DeltaTime;					
				}
				
				return c;
			}
			
			vec4 UpdateRotation(int p_state,vec4 p_status,vec4 p_current)
			{
				vec4 p   = p_status;
				vec4 c   = p_current;
				c = vec4(0,0,0,0);
				return c;
			}
			
			vec4 UpdateSize(int p_state,vec4 p_status,vec4 p_current)
			{
				vec4 p   = p_status;
				vec4 c   = p_current;
				
				if(int(p.x) == PARTICLE_DISABLED)
				{
					float r = p.z <= 0.0 ? 0.0 : (p.y/p.z);
					c.xyz = Lerp(StartSize0.xyz,StartSize1.xyz,ParticleStart().y) * Lerp(LifeSize0.xyz,LifeSize1.xyz,r);
				}
				
				if(int(p.x) == PARTICLE_ENABLED)
				{
					float r = p.z <= 0.0 ? 0.0 : (p.y/p.z);
					c.xyz = Lerp(StartSize0.xyz,StartSize1.xyz,ParticleStart().y) * Lerp(LifeSize0.xyz,LifeSize1.xyz,r);
				}
				
				return c;
			}
			
			
			vec4 UpdateColor(int p_state,vec4 p_status,vec4 p_current)
			{
				vec4 p   = p_status;
				vec4 c   = p_current;
				
				if(int(p.x) == PARTICLE_DISABLED)
				{
					vec4 c0 = texture2D(StartColor,vec2(ParticleStart().z,0.0));
					float r = p.z <= 0.0 ? 0.0 : (p.y/p.z);
					vec4 c1 = texture2D(Color,vec2(r,0.0));
					c = c0 * c1;
				}
				
				if(int(p.x) == PARTICLE_ENABLED)
				{
					vec4 c0 = texture2D(StartColor,vec2(ParticleStart().z,0.0));
					float r = p.z <= 0.0 ? 0.0 : (p.y/p.z);
					vec4 c1 = texture2D(Color,vec2(r,0.0));
					c = c0 * c1;
				}
				
				return c;
			}
			
			vec4 UpdateStart(int p_state,vec4 p_status,vec4 p_current)
			{
				vec4 p   		= p_status;				
				vec4 c   		= p_current;
				
				if(int(p.x) == PARTICLE_DISABLED)
				{
					vec4 rnd = Random();
					c.x = StartSpeed.w > 0.0 ? rnd.x : SystemProgress;
					c.y = StartSize1.w > 0.0 ? rnd.y : SystemProgress;
					c.z = SystemProgress;
					c.w = StartRotation1.w > 0.0 ? rnd.w : SystemProgress;
				}
								
				return c;
			}
			
			void main(void) 
			{		
				float count		 = floor(SystemEmissionCount);
				if(count <= 0.0) { gl_FragColor = vec4(0,0,0,1); return; }
				float ix	     = iterator.x;
				float iy	     = iterator.y;		
				float iw         = 1.0/width;
				float ih         = 1.0/height;				
				float max_count  = ((width * height)/PARTICLE_LENGTH);
				float px         = floor(ix*(width));
				float py         = floor(iy*(height));
				float pix	     = fragment_id = floor(px + (py * width));
				float id		 = particle_id = floor((pix / PARTICLE_LENGTH));
				float field		 = mod(pix,PARTICLE_LENGTH);
				
				float emin 		 = floor(mod(SystemEmissionStart,max_count));
				float emax 		 = floor(mod(SystemEmissionStart+count-1.0,max_count));
				
				if(emin > emax)
				{
					if(id < emin) 
					if(id > emax) { gl_FragColor = vec4(0.0,0.0,0.0,1.0); return; }
				}
				else
				{				
					if(id < emin) { gl_FragColor = vec4(0.0,0.0,0.0,1.0); return; }
					if(id > emax) { gl_FragColor = vec4(0.0,0.0,0.0,1.0); return; }
				}
				/*
				if(int(field)==0) { gl_FragColor = vec4(1.0,0.0,0.0,1.0); return; }
				if(int(field)==1) { gl_FragColor = vec4(1.0,1.0,0.0,1.0); return; }
				if(int(field)==2) { gl_FragColor = vec4(0.0,1.0,0.0,1.0); return; }
				if(int(field)==3) { gl_FragColor = vec4(0.0,1.0,1.0,1.0); return; }
				if(int(field)==4) { gl_FragColor = vec4(0.0,0.0,1.0,1.0); return; }
				if(int(field)==5) { gl_FragColor = vec4(1.0,0.0,1.0,1.0); return; }
				if(int(field)==6) { gl_FragColor = vec4(0.5,0.5,0.5,1.0); return; }
				//*/
				//gl_FragColor = vec4(1.0,1.0,0.0,1.0);				return;
				//if(id >= SystemEmission) { gl_FragColor = vec4(0.0,0.0,0.0,1.0); return; }
				
				int   state		 = SystemState;
				
				vec4  status	 = ParticleStatus();
				vec4  data		 = texture2D(Data,iterator);
				
				gl_FragColor 	 = data;
				
				if(state == STATE_NONE) return;
				
				int field_id        = int(field);
				
				if(field_id == PARTICLE_STATUS) 	{ gl_FragColor = UpdateStatus(state,data);			   	return; }
				if(field_id == PARTICLE_POSITION) 	{ gl_FragColor = UpdatePosition(state,status,data); 	return; }				
				if(field_id == PARTICLE_ROTATION) 	{ gl_FragColor = UpdateRotation(state,status,data); 	return; }				
				if(field_id == PARTICLE_SIZE)	 	{ gl_FragColor = UpdateSize(state,status,data); 	 	return; }				
				if(field_id == PARTICLE_VELOCITY)	{ gl_FragColor = UpdateVelocity(state,status,data); 	return; }
				if(field_id == PARTICLE_COLOR)		{ gl_FragColor = UpdateColor(state,status,data); 	 	return; }
				if(field_id == PARTICLE_START)		{ gl_FragColor = UpdateStart(state,status,data); 	 	return; }
				
			}
			
		</fragment>	
</shader>