# OQ_Analysis Variables Documentation
OpenStreetMap Quality Analysis Tools 
<img align="right" width="132" height="132" src="img/OQi_132.png">


**TANGLE** Classification of angles / geometries based on degree tolerance vs Angles analysed

| Angle         | Tolerance +-2 | Tolerance +- 5 | Tolerance +- 10 |
|----------------:|-----------|------------|-------------|
| 180          | *ignored* |      DD      |             |
|  90, 270     |       Q    |     QQ       |    QQQ         |
|  45, 135, 225, 315   |       H        |       HH         |                 |
| Regular (octo, etc)  |       R        |       RR         |                 |
| Otherwise   IR         |               |                |                 |

**ways_topology** 	( id bigint NOT NULL, id_b bigint, teval text, eval jsonb)
- id   : OSM id of the polygon
- id_b : OSM id of the second polygon (Topological Analysis)
- teval : FB (Geometry form warning),  XB-XO Topological Errors
- eval :  Json list with various metrics to analyse the polygon

**The Eval Json list contains the following keys:values:** 
- grp_tag: building or other
- flag = 0 , regular polygon
- flag = 1 , Irregular forms and Invalid topology
- nb_points: polygon number of points
- nb_angles: number of angles
- type_angle_list : Polygon list : Geometry evaluaiton of each Angle  tangle =[r, r, rr, ir, qq, qqq, etc]
- type_geom  :  Polygon : Geometry summary, type_angle ex: [r-rr-qq-qqq-ir]
- type_polygon : Polygon Classified from Irregular to Regular (Starts from Geometry further from Regular with symbols [r-ir])
    * Invalid
    * Open
   * Small (less then 4 angles)
   * Micro (less then 2m2)
   * ir  (for [q-h-hh-qqq-ir]
   * rrr (for [q-h-hh-qqq]
   * rr  (for [q-h-hh-dd]
   * r   (for [q-h-r]

