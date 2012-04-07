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
import java.nio.*;


/*
Class: VectorBuffer

This class acts as a replacement to the OpenGL vertex operations, 
allowing them to be performed in a thread safe manner.  It also implements 
float buffers so that it gets drawn much quicker than if the operations were 
performed in the application draw cycle. This class is intended to be used 
to build models at run-time.
*/
class VectorBuffer {
  private FloatBuffer vertexBuffer;
  private FloatBuffer normalBuffer;
  
  private Stack transformationMatrixStack;
  private float[] transformationMatrix;
  
  private int bufferedVectors;  
  private int bufferSize;
  
  /*
  Private Method: transformVector
  
  vector - The vector which will be transformed.
  isNormal - True if [vector] describes a normal, false if it is a vertex. 
             If it is a normal, translations will not be applied.
  
  Returns [vector] multiplied by the current transformation matrix.
  */
  private PVector transformVector(PVector vector, boolean isNormal) {    
    float newX = vector.x * transformationMatrix[0] + vector.y * transformationMatrix[4] + vector.z * 
                transformationMatrix[8] + ((isNormal) ? 0 : transformationMatrix[12]);
                
    float newY = vector.x * transformationMatrix[1] + vector.y * transformationMatrix[5] + vector.z * 
                transformationMatrix[9]  + ((isNormal) ? 0 : transformationMatrix[13]);
                     
    float newZ = vector.x * transformationMatrix[2] + vector.y * transformationMatrix[6] + vector.z * 
                transformationMatrix[10]  + ((isNormal) ? 0 : transformationMatrix[14]);
    
    return new PVector(newX, newY, newZ);
    
  }
  
  /*
  Private Method: createTransformationMatrix
    
  Returns a float array with 16 locations, which describes a 4x4 identity matrix. The array locations
  correspond to the matrix as follows, let x be the array:
  
  x[0] x[4] x[8] x[12]
  x[1] x[5] x[9] x[13]
  x[2] x[6] x[10] x[14]
  x[3] x[7] x[11] x[15]
  
  */
  private float[] createTransformationMatrix() {
    float[] result = new float[16];
    
    for(int i = 0; i < result.length; i++) {
      result[i] = 0;
    }
    
    result[0] = 1;
    result[5] = 1;
    result[10] = 1;
    result[15] = 1;
    
    return result;
  }
  /*
  Constructor: VectorBuffer
    
  bufferSize - The number of records which will be stored in this buffer -- one 
               vertex and it's normal are considered one record.
  */
  public VectorBuffer(int bufferSize) {
    this.vertexBuffer = BufferUtil.newFloatBuffer(bufferSize * 3);
    this.normalBuffer = BufferUtil.newFloatBuffer(bufferSize * 3);

    this.bufferSize = bufferSize;  
    this.transformationMatrix = createTransformationMatrix();
    
    transformationMatrixStack = new Stack();
  }
  /*
  Method: size
  
  Returns the number of records which have been added to this buffer.
  */
  public int size() {   
    return bufferedVectors;
  }
  /*
  Method: capacity
  
  Returns the maximum number of records that this buffer can store.
  */
  public int capacity() {    
    return bufferSize;
  }
  
  /*
  Method: buffer
  
  Adds the given normal and vertex as a record in the buffer. 
  
  Note: 
    The current transformation matrix is applied to the vectors before
    they are stored.
  
  nx - The x component of the normal. 
  ny - The y component of the normal. 
  nz - The z component of the normal. 
  
  vx - The x offset of the vertex.
  vy - The y offset of the vertex.
  vz - The z offset of the vertex.
  */
  public void buffer(float nx, float ny, float nz, float vx, float vy, float vz) {
    PVector normalVector =  transformVector(new PVector(nx, ny, nz), true);
    PVector vertexVector =  transformVector(new PVector(vx, vy, vz), false);
    
    normalBuffer.put(normalVector.x);
    normalBuffer.put(normalVector.y);
    normalBuffer.put(normalVector.z);
    
    vertexBuffer.put(vertexVector.x);
    vertexBuffer.put(vertexVector.y);
    vertexBuffer.put(vertexVector.z);
    
    bufferedVectors++;
  }
  
  /*
  Method: rewind
  
  Moves the current position of the buffer back to the first record.
  */
  public void rewind() {
    vertexBuffer.rewind();
    normalBuffer.rewind();
  }
  
  /*
  Method: pushMatrix
  
  Pushes a copy of the current transformation matrix on the stack, saving it.
  
  Note:
    This is equivilent to the Processing method of the same name. 
  
  */
  public void pushMatrix() {
    transformationMatrixStack.push(transformationMatrix.clone());
  }
  
  
  /*
  Method: popMatrix
  
  Pops the topmost matrix from the stack and replaces the current transformation matrix with it.
    
  Note:
    This is equivilent to the Processing method of the same name. 
  
  */
  public void popMatrix() {
    transformationMatrix = (float[])transformationMatrixStack.pop();
  }
  
  
  /*
  Method: translate
  
  Applies a translation matrix to the current transformation matrix, effectively
  offsetting the current origin by the given vector.
  
  tx - The x offset which will be applied.
  ty - The y offset which will be applied.
  tz - The z offset which will be applied.
      
  Note:
    This is equivilent to the Processing method of the same name. 
  
  */
  public void translate(float tx, float ty, float tz) { 
    float[] translationMatrix = createTransformationMatrix();
    
    translationMatrix[12] = tx;
    translationMatrix[13] = ty;
    translationMatrix[14] = tz;
    
    multMatrix(translationMatrix);
  }
  
  /*
  Method: rotate
  
  Applies an arbitrary rotation matrix to the current transformation matrix, effectively
  rotating the current origin by the given angle, along the given axis.
  
  angle - The angle, in radians, which will be applied to the rotation.

  x - The x component of the axis of rotation.
  y - The y component of the axis of rotation.
  z - The z component of the axis of rotation.
      
  Note:
    This is equivilent to the Processing method of the same name. 
  
  */
  public void rotate(float angle, float x, float y, float z) {
    float t = 1 - cos(angle);
    float c = cos(angle);
    float s = sin(angle);
    
    float[] rotationMatrix = createTransformationMatrix();
    
    rotationMatrix[0] = t*x*x + c;
    rotationMatrix[4] = t*x*y + s*z;
    rotationMatrix[8] = t*x*z - s*y;
    
    rotationMatrix[1] = t*x*y - s*z;
    rotationMatrix[5] = t*y*y + c;
    rotationMatrix[9] = t*y*z + s*x;
    
    rotationMatrix[2] = t*x*y + s*y;
    rotationMatrix[6] = t*y*z - s*x;
    rotationMatrix[10] = t*z*z + c;
    
    multMatrix(rotationMatrix);
  }  
  /*
  Method: multMatrix
  
  Multiplies the transformation matrix by the given matrix, and replaces the 
  transformation matrix with the result.
  
  matrix: The 4x4 matrix, in the form of a float array with 16 locations, which 
          will be multiplied with the transformation matrix. The array locations
          correspond to the matrix as follows, let x be the array:
          
          x[0] x[4] x[8] x[12]
          x[1] x[5] x[9] x[13]
          x[2] x[6] x[10] x[14]
          x[3] x[7] x[11] x[15]
      
  Note:
    * This is equivilent to the opengl function glMultMatrix.
    
    * The transfomation matrix and [matrix] are multiplied in the following
      order: transformation matrix * [matrix]. Remember matrix multiplication is
      non-commutative.  
      
  */
  public void multMatrix(float[] matrix) {
    float[] result = new float[16];
    
    for(int i = 0; i < 4; i++) {
      for(int j = 0; j < 4; j++) {        
        for(int k = 0; k < 4; k++) {
          result[j + i*4] += transformationMatrix[k*4 + j] * matrix[k + i*4];
        }
      }
    }
    
    transformationMatrix = result;
  }
  
  /*
  Method: draw
  
  Outputs the contents of the vector buffer to OpenGL.
  */
  public void draw() {    
    PGraphicsOpenGL pgl = (PGraphicsOpenGL) g; 
    
    GL gl = pgl.beginGL();  
      gl.glVertexPointer(3, GL.GL_FLOAT, 0, vertexBuffer); 
      gl.glNormalPointer(GL.GL_FLOAT, 0, normalBuffer); 
      
      gl.glDrawArrays(GL.GL_TRIANGLES, 0, bufferSize);
    pgl.endGL(); 
  }
}
