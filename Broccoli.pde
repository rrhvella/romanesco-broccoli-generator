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

final float GOLDEN_ANGLE = 2.399963;
/*
Constant: INNER_TO_OUTER_CONE_RATIO

The radius of the cone "inside the broccoli" (i.e. the cone on which the other cones are placed) 
compared to the one "outside" (The approximate area the broccoli and all it's cones cover).
*/
final float INNER_TO_OUTER_CONE_RATIO = 0.4325;
/*
Constant: RADIUS_TO_LENGTH_RATIO

The radius of the cone inside the broccoli as compared to its length.
*/
final float RADIUS_TO_LENGTH_RATIO = 0.9534;

final PVector UP_VECTOR = new PVector(0, -1, 0);
/*
Class: RomanescoBroccoliNode

Handles the construction, management, and drawing of a Romanesco broccoli. This
class implements the runnable interface, and is perfectly thread safe.
*/
public class RomanescoBroccoliNode implements Runnable {
  private VectorBuffer vectorBuffer;

  private float altitude;
  private int detail;
  private int numberOfConesOnSurface;
  private int numberOfLevels;
  /*
  Constructor: RomanescoBroccoliNode
  
  altitude - The length of the broccoli along it's spine.
  detail - The detail which is used to draw the cones on the broccoli's surface.
  numberOfConesOnSurface - The number of cones on the surface of this broccoli.
                        
                         Note: Unless there are no more levels, this number is also 
                               the number of cones on the cones of this broccoli -- since
                               the cones on the surface of this broccoli would themselves
                               be broccolis.
                              
  numberOfLevels - The remaining number of levels in the broccoli fractal.
  
  */
  public RomanescoBroccoliNode(float altitude, int detail, int numberOfConesOnSurface, int numberOfLevels) {
    this.vectorBuffer = new VectorBuffer(getNumberOfVectorsInBroccoli(detail, numberOfConesOnSurface, numberOfLevels));    
    
    this.altitude = altitude;
    
    this.detail = detail;
    this.numberOfConesOnSurface = numberOfConesOnSurface;
    
    this.numberOfLevels = numberOfLevels;
  }
  
  public float getProgress() {
    return float(vectorBuffer.size()) / vectorBuffer.capacity();
  }
  
  public void run() {
    bufferRomanescoBroccoli(altitude, detail, numberOfConesOnSurface, numberOfLevels, vectorBuffer);
    vectorBuffer.rewind();
  }
  
  public void draw() {
    vectorBuffer.draw();  
  }
}
/*
Method: bufferRomanescoBroccoli

altitude - The length of the broccoli along it's spine.
detail - The detail which is used to draw the cones on the broccoli's surface.
numberOfConesOnSurface - The number of cones on the surface of this broccoli.
                      
                       Note: Unless there are no more levels, this number is also 
                             the number of cones on the cones of this broccoli -- since
                             the cones on the surface of this broccoli would themselves
                             be broccolis.
                            
numberOfLevels - The remaining number of levels in the broccoli fractal.
vectorBuffer - The buffer where the vertices and normals used to build this broccoli will be stored.
*/
public void bufferRomanescoBroccoli(float altitude, int detail, int numberOfConesOnSurface, int numberOfLevels,
      VectorBuffer vectorBuffer) {

  bufferRomanescoBroccoli(altitude, detail, numberOfConesOnSurface, numberOfLevels, vectorBuffer, 0, null, null);
}
/*
Method: bufferRomanescoBroccoli

altitude - The length of the broccoli along it's spine.
detail - The detail which is used to draw the cones on the broccoli's surface.
numberOfConesOnSurface - The number of cones on the surface of this broccoli.
                      
                       Note: Unless there are no more levels, this number is also 
                             the number of cones on the cones of this broccoli -- since
                             the cones on the surface of this broccoli would themselves
                             be broccolis.
                            
numberOfLevels - The remaining number of levels in the broccoli fractal.
vectorBuffer - The buffer where the vertices and normals used to build this broccoli will be stored.
angleOfRotation - The angle, in radians, between the origin's current axis and the cone's spine.
axisOfRotation - The axis along which the angle of rotation is applied.
position - The offset of the center of the cone from the current origin.
*/
public void bufferRomanescoBroccoli(float altitude, int detail, int numberOfConesOnSurface, int numberOfLevels, VectorBuffer buffer,
      float angleOfRotation, PVector axisOfRotation, PVector position) {
        
  buffer.pushMatrix();
  
  if(axisOfRotation != null && position != null) {
    buffer.translate(position.x, position.y, position.z);
    buffer.rotate(angleOfRotation, axisOfRotation.x, axisOfRotation.y, axisOfRotation.z);
  }
  
  float radiusAtBase = RADIUS_TO_LENGTH_RATIO * altitude; 
  
  PVector centerOfConeBase = new PVector(0, altitude / 2, 0);
  PVector topOfCone = PVector.mult(centerOfConeBase, -1);
     
  if(numberOfLevels <= 0) {
    //Only the topmost cones are actually drawn, as drawing the other cones, which are generally hidden,
    //would  require a lot of memory.
    bufferCone(altitude, radiusAtBase, detail, buffer);
  } else { 
    float innerRadius = radiusAtBase * INNER_TO_OUTER_CONE_RATIO;
    
    //Get the number which falls between the outer radius and the inner radius
    float medianRadius = (radiusAtBase - innerRadius) / 2.0 + innerRadius;  
    
    //Iterate through the positions of the other broccoli nodes on this broccoli's surface
    ConicSpiralIterator spiralIterator = new ConicSpiralIterator(GOLDEN_ANGLE, altitude, medianRadius, numberOfConesOnSurface);
    
    PVector currentCoordinate = spiralIterator.next();
    
    while(currentCoordinate != null) {   
      //Get position of the new broccoli node
      PVector subNodePosition = new PVector(currentCoordinate.x, currentCoordinate.y, currentCoordinate.z);  
      
      //Get the direction of the new broccoli node in relation to this broccoli's base
      PVector directionOfCoordinateFromBase = PVector.sub(currentCoordinate, centerOfConeBase);
      directionOfCoordinateFromBase.normalize();
                        
                        
      //Get the position of the new broccoli node's center if it were projected on the circumference of this broccoli's base.
      PVector coordinateAtConeBase = new PVector(currentCoordinate.x, 0, currentCoordinate.z);
      coordinateAtConeBase.mult(innerRadius / coordinateAtConeBase.mag());
      coordinateAtConeBase.y = centerOfConeBase.y;
      
      //Calculate the new broccoli node's orientation (axis of rotation and angle) from the broccoli.
      PVector directionOfTopFromCoordinateAtConeBase = PVector.sub(topOfCone, coordinateAtConeBase);
      directionOfTopFromCoordinateAtConeBase.normalize();
      
      PVector perpendicularDirectionToCone = directionOfTopFromCoordinateAtConeBase.cross(directionOfCoordinateFromBase);
      perpendicularDirectionToCone = directionOfTopFromCoordinateAtConeBase.cross(perpendicularDirectionToCone);
      perpendicularDirectionToCone.normalize();
      
      perpendicularDirectionToCone.mult(-1);
              
      float subNodeAngleOfRotation = -PVector.angleBetween(UP_VECTOR, perpendicularDirectionToCone);
      
      PVector subNodeAxisOfRotation = UP_VECTOR.cross(perpendicularDirectionToCone);
      subNodeAxisOfRotation.normalize();
      
      PVector intersectionBetweenConeAndCurrentVector = intersectionBetweenTwoLines(centerOfConeBase, currentCoordinate, topOfCone, coordinateAtConeBase);
      
      //As the current coordinate is actually the center of the  new broccoli node, the actual length of the  new broccoli node is the distance
      //from the current coordinate and this broccoli's inner cone surface, multiplied by 2.
      float lengthOfSurfaceCone = currentCoordinate.dist(intersectionBetweenConeAndCurrentVector) * 2;
     
      //Buffer the vectors and normals of the new broccoli node.
      bufferRomanescoBroccoli(lengthOfSurfaceCone, detail, numberOfConesOnSurface, numberOfLevels - 1, buffer,
                subNodeAngleOfRotation, subNodeAxisOfRotation, subNodePosition);
      
      //Get the position of the next node.
      currentCoordinate = spiralIterator.next();
   }
  }
  
  buffer.popMatrix();
}
