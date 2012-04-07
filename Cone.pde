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

/*
Method: bufferCone

Stores the vertices and normals on a cone's surface into the given vector buffer.

altitude - The length of the cone along it's spine.
radiusAtBase - The radius of the circle  at the base of the cone.
detail -  The detail which is used to draw the cone. This is equivilent to the number of divisions 
        along the cone's spine, or those on the circumference of its base, which are used to approximate 
        the surface of the cone.
        
vectorBuffer - The buffer where the vertices and normals on the cone's surface will be stored.
*/
public void bufferCone(float altitude, float radiusAtBase, int detail, VectorBuffer vectorBuffer) {
  float yIncrement = altitude / detail;
  float angleIncrement = TWO_PI / detail;
  float radiusIncrement = radiusAtBase / detail;
  
  float startY = -(altitude / 2);
  float endY = -startY;
  
  PVector centerOfBase = new PVector(0, endY, 0);
  
  for(int i = 1; i <= detail; i++) {
    float radius = radiusIncrement * i;
    float previousRadius = radiusIncrement * (i - 1);
      
    float y = startY + yIncrement * i;  
    float previousY = startY + yIncrement * (i - 1); 
    
    PVector firstNormal = new PVector(radius, y, 0);
    firstNormal.sub(centerOfBase);
    firstNormal.normalize();
    
    for(int j = 1; j <= detail; j++) {
      float angle = angleIncrement * j;       
      float previousAngle = angleIncrement * (j - 1);
      
      //Calculate corners and normals of approximate surface triangles.
      PVector topLeftCorner = new PVector(cos(previousAngle) * previousRadius, previousY, sin(previousAngle) * previousRadius);        
      PVector topRightCorner = new PVector(cos(angle) * previousRadius, previousY, sin(angle) * previousRadius);
      PVector bottomRightCorner = new PVector(cos(angle) * radius, y, sin(angle) * radius);        
      PVector bottomLeftCorner = new PVector(cos(previousAngle) * radius, y, sin(previousAngle) * radius);
      
      PVector normal1 = calculateTriangleNormal(topLeftCorner, bottomLeftCorner, bottomRightCorner); 
      PVector normal2 = calculateTriangleNormal(bottomRightCorner, topRightCorner, topLeftCorner);
      
      //Buffer approximate surface
    
      vectorBuffer.buffer(normal1.x, normal1.y, normal1.z, topLeftCorner.x, topLeftCorner.y, topLeftCorner.z);      
      vectorBuffer.buffer(normal1.x, normal1.y, normal1.z, bottomLeftCorner.x, bottomLeftCorner.y, bottomLeftCorner.z);
      vectorBuffer.buffer(normal1.x, normal1.y, normal1.z, bottomRightCorner.x, bottomRightCorner.y, bottomRightCorner.z);
      
      vectorBuffer.buffer(normal2.x, normal2.y, normal2.z, bottomRightCorner.x, bottomRightCorner.y, bottomRightCorner.z);
      vectorBuffer.buffer(normal2.x, normal2.y, normal2.z, topRightCorner.x, topRightCorner.y, topRightCorner.z); 
      vectorBuffer.buffer(normal2.x, normal2.y, normal2.z, topLeftCorner.x, topLeftCorner.y, topLeftCorner.z);  
    }             
  }
}

