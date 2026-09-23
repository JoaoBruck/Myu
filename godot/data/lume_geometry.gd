extends RefCounted
## Coordinates use the 1536 x 864 source art. Footprints and silhouettes are separate.
const SCALE := 2.0 / 3.0
static func to_world(polygon: PackedVector2Array) -> PackedVector2Array:
	var result := PackedVector2Array()
	for point in polygon:
		result.append(point * SCALE)
	return result
static func rect(x: float,y: float,w: float,h: float) -> PackedVector2Array:
	return PackedVector2Array([Vector2(x,y),Vector2(x+w,y),Vector2(x+w,y+h),Vector2(x,y+h)])
static func points(values: Array) -> PackedVector2Array:
	var result := PackedVector2Array()
	for i in range(0,values.size(),2):
		result.append(Vector2(values[i],values[i+1]))
	return result
static func blockers() -> Array[Dictionary]:
	return [
		{"name":"WestBoundary","polygon":rect(-40,-40,40,950)},
		{"name":"EastBoundary","polygon":rect(1536,-40,40,950)},
		{"name":"NorthBoundary","polygon":rect(-40,-40,1616,40)},
		{"name":"SouthBoundary","polygon":rect(-40,864,1616,40)},
		{"name":"CafeFacade","polygon":rect(0,0,776,396)},
		{"name":"LeftWall","polygon":rect(0,390,255,40)},
		{"name":"CafePlanterLeft","polygon":rect(264,374,46,44)},
		{"name":"ChairLeft","polygon":rect(315,394,53,30)},
		{"name":"Table","polygon":rect(380,407,45,23)},
		{"name":"ChairRight","polygon":rect(428,397,37,26)},
		{"name":"CafeBoard","polygon":rect(473,430,82,28)},
		{"name":"CafePlanterRight","polygon":rect(684,376,42,38)},
		{"name":"TreeGarden","polygon":points([776,258,948,273,1038,321,1038,414,776,414])},
		{"name":"Bench","polygon":rect(870,416,143,27)},
		{"name":"MainLampBase","polygon":rect(1055,408,38,24)},
		{"name":"Bin","polygon":rect(1183,400,67,28)},
		{"name":"FrontRail","polygon":rect(1038,397,298,25)},
		{"name":"RampRail","polygon":points([1332,396,1494,515,1490,534,1332,421])},
		{"name":"RampLampBase","polygon":rect(1458,509,35,26)},
		{"name":"DirectionPoleBase","polygon":rect(1293,767,26,24)},
		{"name":"River","polygon":points([776,0,1536,0,1536,278,1488,273,1398,256,1324,243,1216,234,1144,239,1050,252,776,257])},
		{"name":"ForegroundLeft","polygon":points([0,466,122,466,133,681,274,683,275,714,356,717,357,806,444,806,449,864,0,864])},
		{"name":"ForegroundRight","polygon":points([1536,539,1515,583,1475,633,1440,677,1460,726,1350,729,1348,783,1240,785,1240,864,1536,864])},
		{"name":"UtilityBase","polygon":rect(1103,811,82,53)},
		{"name":"BottomGarden","polygon":rect(832,828,287,36)}
	]
static func occluders() -> Array[Dictionary]:
	var result: Array[Dictionary] = [
		{"name":"Canopy","base":385.0,"polygon":points([686,0,1140,0,1193,88,1177,153,1102,202,1012,203,961,251,866,278,775,264,755,176,694,121])},
		{"name":"Tree","base":405.0,"polygon":points([784,98,843,112,848,208,913,139,940,140,909,213,865,269,848,390,799,405,798,241,770,181])},
		{"name":"PlanterLeft","base":418.0,"polygon":points([251,310,272,283,305,291,326,331,310,369,305,418,264,418,258,368])},
		{"name":"ChairLeft","base":424.0,"polygon":points([311,345,349,337,358,374,372,383,368,414,354,417,353,397,332,397,330,424,318,424,320,389])},
		{"name":"Table","base":430.0,"polygon":points([370,347,407,338,443,348,444,365,416,373,416,405,433,421,426,430,407,416,387,429,377,425,398,406,398,374,371,367])},
		{"name":"ChairRight","base":424.0,"polygon":points([447,342,468,339,467,421,452,424,451,399,431,399,432,416,420,417,423,380,438,368])},
		{"name":"CafeBoard","base":458.0,"polygon":points([470,339,551,340,561,451,551,460,474,460,466,452])},
		{"name":"PlanterRight","base":414.0,"polygon":points([678,319,689,287,712,282,734,317,735,355,727,380,725,414,683,414,675,364])},
		{"name":"Bench","base":443.0,"polygon":points([870,352,1013,350,1017,443,1002,443,1001,423,886,423,884,443,867,443])},
		{"name":"MainLamp","base":432.0,"polygon":points([1063,11,1082,10,1087,35,1119,35,1122,55,1137,69,1138,99,1128,119,1101,119,1090,93,1094,61,1089,55,1087,283,1100,312,1096,428,1055,433,1053,313,1064,287])},
		{"name":"Bin","base":429.0,"polygon":rect(1182,321,74,108)},
		{"name":"DirectionBoards","base":791.0,"polygon":rect(1266,420,139,116)},
		{"name":"DirectionPole","base":791.0,"polygon":rect(1292,531,25,260)},
		{"name":"RampLamp","base":535.0,"polygon":points([1441,196,1459,197,1468,217,1465,244,1475,258,1472,289,1464,300,1489,379,1495,514,1485,535,1457,529,1456,390,1462,372,1449,301,1437,290,1433,260,1444,247])},
		{"name":"ForegroundLeft","base":864.0,"polygon":points([0,464,128,464,132,511,176,511,198,530,207,578,249,578,251,611,286,612,309,650,342,653,365,681,409,678,417,720,451,721,472,747,501,757,513,810,534,810,544,864,0,864])},
		{"name":"ForegroundRight","base":864.0,"polygon":points([1536,470,1490,487,1486,536,1460,560,1435,592,1447,625,1420,642,1428,694,1360,713,1344,779,1240,781,1230,754,1204,763,1184,804,1134,819,1120,864,1536,864])},
		{"name":"UtilityPoles","base":864.0,"polygon":points([1107,631,1131,628,1131,647,1143,647,1141,629,1168,627,1171,649,1182,652,1180,757,1189,768,1179,864,1100,864,1100,761,1106,749])}
	]
	# Draw separate rails so empty spaces never hide the player.
	result.append({"name":"FrontRailTop","base":422.0,"polygon":rect(845,336,489,13)})
	for x in range(851,1331,29):
		result.append({"name":"RailBar%d" % x,"base":422.0,"polygon":rect(x,347,7,55)})
	result.append({"name":"FrontRailBottom","base":422.0,"polygon":rect(844,391,489,12)})
	result.append({"name":"RailStone","base":420.0,"polygon":rect(813,318,39,102)})
	result.append({"name":"RampTop","base":534.0,"polygon":points([1334,336,1491,444,1490,458,1334,350])})
	result.append({"name":"RampBottom","base":534.0,"polygon":points([1336,396,1490,514,1489,528,1336,410])})
	for i in 6:
		result.append({"name":"RampBar%d" % i,"base":534.0,"polygon":rect(1350.0+i*25.0,358.0+i*17.8,8,57)})
	return result
