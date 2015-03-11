<shader id="haxor/internal/Skybox">
  <vertex precision="medium">  
	
    uniform mat4 ViewMatrixInverse;
    uniform mat4 SkyboxProjectionMatrixInverse;
    uniform vec3 WSCameraPosition;    
    
	varying vec3 WSView;	
	
	attribute vec3 vertex;
	
	
    void main()
    {
		vec4 v = vec4(vertex,1.0);;
		vec4 ws_vertex = v * SkyboxProjectionMatrixInverse;
		ws_vertex /= ws_vertex.w;
		ws_vertex = ws_vertex * ViewMatrixInverse;
		WSView = ws_vertex.xyz - WSCameraPosition;      		
		gl_Position = v;
    }
  </vertex>

  <fragment precision="medium">
  	
    uniform samplerCube  SkyboxTexture;
    varying vec3 WSView;
	
    void main() 
	{ 		
		gl_FragColor = textureCube(SkyboxTexture,normalize(WSView));		
	}
	
  </fragment>  
</shader>
