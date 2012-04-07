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
Method: intersectionBetweenTwoLines

line1Start - The coordinate where line1 starts.
line1End - The coordinate where line1 ends.

line2Start - The coordinate where line2 starts.
line2End - The coordinate where line2 ends.

Returns the coordinate at which the given lines intersect.
*/
PVector intersectionBetweenTwoLines(PVector line1Start, PVector line1End, 
                                    PVector line2Start, PVector line2End) {
  PVector a = PVector.sub(line1End, line1Start);
  PVector b = PVector.sub(line2End, line2Start);
  PVector c = PVector.sub(line2Start, line1Start);
  
  float innerQuotient = PVector.dot(c.cross(b), a.cross(b));
  innerQuotient /= (pow(a.cross(b).mag(), 2));
  
  PVector intersection = PVector.add(line1Start, PVector.mult(a, innerQuotient));
  
  return intersection;
}
/*
Method: calculateTriangleNormal

corner[1-3] - The three corners of the triangle which will be analyzed.

Returns the surface normal of the triangle with the given corners.
*/
PVector calculateTriangleNormal(PVector corner1, PVector corner2, PVector corner3) {
  PVector edgeVector1 = PVector.sub(corner2, corner1);
  PVector edgeVector2 = PVector.sub(corner3, corner1);
  
  PVector result = edgeVector1.cross(edgeVector2);
  result.normalize();
  
  return result;
}
/*
Method: getNumberOfVectorsInCone

detail - The detail which is used to draw the cone. This is equivilent to the number of divisions 
        along the cone's spine, or those on the circumference of its base, which are used to approximate 
        the surface of the cone.

Returns the number of vectors needed to draw the cone.
*/
int getNumberOfVectorsInCone(int detail) {
  return detail*detail*6;
}

/*
Method: getNumberOfVectorsInBroccoli

detail - The detail which is used to draw the cones on the broccoli's surface.
numberOfConesOnSurface - The number of cones on the surface of this broccoli.
                        
                         Note: Unless there are no more levels, this number is also 
                               the number of cones on the cones of this broccoli -- since
                               the cones on the surface of this broccoli would themselves
                               be broccolis.
                               
numberOfLevels - The remaining number of levels in the broccoli fractal.
*/
int getNumberOfVectorsInBroccoli(int detail, int numberOfConesOnSurface, int numberOfLevels) {
  return int(pow(numberOfConesOnSurface, numberOfLevels)) * getNumberOfVectorsInCone(detail);  
}
