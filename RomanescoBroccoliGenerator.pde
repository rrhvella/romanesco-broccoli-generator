/*
Romanesco Broccoli
-------------------

Romanesco Broccoli - Copyright (c) 2010 Robert Vella - robert.r.h.vella@gmail.com

This software is provided 'as-is', without any express or
implied warranty. In no event will the authors be held
liable for any damages arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute
it freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented;
   you must not claim that you wrote the original software.
   If you use this software in a product, an acknowledgment
   in the product documentation would be appreciated but
   is not required.

2. Altered source versions must be plainly marked as such,
   and must not be misrepresented as being the original software.

3. This notice may not be removed or altered from any
   source distribution.
*/

import javax.media.opengl.*;
import javax.media.opengl.glu.*;
import com.sun.opengl.util.*;
import processing.opengl.*;

final float BROCCOLI_COLOR_RED = 0.5742;
final float BROCCOLI_COLOR_GREEN = 0.8554;
final float BROCCOLI_COLOR_BLUE = 0.4375;

float yRotation = 0;
RomanescoBroccoliNode romanescoBroccoli;

Thread broccoliBuildingThread;

void setup() {
  size(640, 480, OPENGL);  
  colorMode(1, 1, 1, RGB);
  
  noStroke();
    
  PGraphicsOpenGL pgl = (PGraphicsOpenGL) g; 
  
  GL gl = pgl.beginGL();  
    gl.glEnable(GL.GL_CULL_FACE);
    
    gl.glEnableClientState(GL.GL_VERTEX_ARRAY);
    gl.glEnableClientState(GL.GL_NORMAL_ARRAY);
  pgl.endGL();  
  
  resetMatrix();
  
  romanescoBroccoli = new RomanescoBroccoliNode(100.0f, 17, 50, 2);

  broccoliBuildingThread = new Thread(romanescoBroccoli);
  broccoliBuildingThread.start();
 
}

void draw() {
 background(0);
 
 if(!broccoliBuildingThread.isAlive()) {
    //Draw broccoli. 
    translate(width / 2.0, height / 2, 200);
    rotateY(yRotation);
    
    PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;
    //For some reason the processing light and material 
    //functions don't work if you use FloatBuffers.
    GL gl = pgl.beginGL();
      gl.glEnable(GL.GL_LIGHTING);
      gl.glEnable(GL.GL_LIGHT0);
      gl.glEnable(GL.GL_DEPTH_TEST);
      
      gl.glMaterialfv(GL.GL_FRONT, GL.GL_AMBIENT_AND_DIFFUSE, new float[]{BROCCOLI_COLOR_RED, 
        BROCCOLI_COLOR_GREEN, BROCCOLI_COLOR_BLUE, 1.0}, 0);
        
      gl.glMaterialfv(GL.GL_FRONT, GL.GL_SPECULAR, new float[]{BROCCOLI_COLOR_RED * 0.5, BROCCOLI_COLOR_GREEN * 0.5, 
        BROCCOLI_COLOR_BLUE * 0.5, 1.0}, 0);
        
      gl.glMaterialfv(GL.GL_FRONT, GL.GL_SHININESS, new float[]{BROCCOLI_COLOR_RED * 0.25, BROCCOLI_COLOR_GREEN * 0.25, 
        BROCCOLI_COLOR_BLUE * 0.25, 1.0}, 0);
    pgl.endGL(); 
    
    romanescoBroccoli.draw();
    
    yRotation += 0.01;
 } else {
    //Draw progress bar.
    fill(0.5, 0.5, 0.5);
    rect(width * 0.25, height * 0.45, width * 0.5, height * 0.10);
    
    fill(BROCCOLI_COLOR_RED, BROCCOLI_COLOR_GREEN, BROCCOLI_COLOR_BLUE);
    rect(width * 0.27, height * 0.47, width * 0.46 * (romanescoBroccoli.getProgress()), height * 0.06);
 } 
}
