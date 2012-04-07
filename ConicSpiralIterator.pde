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
Class: ConicSpiralIterator

Iterates through the coordinates on a three-dimensional conic spiral. Starting from the top
and moving to the bottom. Depending on the detail required, the iterator will move down the spine
of the cone, and rotate at a given angle, before returning a coordinate on the cone's surface
*/
class ConicSpiralIterator { 
   float angle;
   float altitude;
   
   int detail;
   float segmentLength;
   
   float yStart;   
   
   float currentIndex;
   float tanAngle;
  /*
  Constructor: ConicSpiralIterator
  
  angle - The circular angle, in radians, between each generated coordinate.
  altitude - The altitude of the cone from which the coordinates will be sampled.
  radiusAtBase - The radius of the circle at the base of the cone.
  detail - The total number of coordinates which will be sampled from this iterator.
  */
  ConicSpiralIterator(float angle, float altitude, float radiusAtBase, int detail) {
   this.angle = angle;
   this.altitude = altitude;
   
   this.detail = detail; 
   this.segmentLength = altitude / detail;
   this.tanAngle = radiusAtBase / altitude;
   
   this.yStart = 0 - altitude / 2;
   
   this.currentIndex = 0;
  }
  /*
  Method: next
  
  Returns the next coordinate in the series.
  
  Note: 
    The iterator will also move down the spine of the cone, and rotate
    according to the angle given in the constructor.
  */
  PVector next() {
    if(currentIndex == detail) {
      return null;
    }
    
    float spineProgress = currentIndex * segmentLength;
    float newAngle = (angle * currentIndex);
    float radius = tanAngle * spineProgress;
    
    float x = cos(newAngle) * radius;
    float y = yStart + spineProgress;       
    float z = sin(newAngle) * radius;
    
    currentIndex++;
    
    return new PVector(x, y, z);    
  }  
}
