' Line Segment Tracer - QB64 Basic Variant
' A library for tracing line segments, identifying junctions, and detecting loops
' Updated to use LineSeg type with polyline tracking
' NOTE: QB64 cannot return Types, so we use separate x,y coordinates or modify structures by reference

TYPE Point
    x AS DOUBLE
    y AS DOUBLE
END TYPE

TYPE LineSeg
    x1 AS DOUBLE
    y1 AS DOUBLE
    x2 AS DOUBLE
    y2 AS DOUBLE
    p1 AS Point
    p2 AS Point

    Sn AS DOUBLE ' Sine of angle
    Cs AS DOUBLE ' Cosine of angle
    Ang AS DOUBLE ' Angle
    Dist AS DOUBLE ' Distance/Length

    Trim1 AS DOUBLE ' Trim start
    Trim2 AS DOUBLE ' Trim end

    ringId AS INTEGER ' Ring/Loop identifier
    active AS INTEGER ' 0=inactive, -1=active
    selected AS INTEGER ' 0=not selected, -1=selected
    pocket AS INTEGER ' Pocket identifier
    bad AS INTEGER ' 0=valid, -1=invalid
    count AS INTEGER ' Reference count
END TYPE

TYPE Junction
    point AS Point
    connectedCount AS LONG
    degree AS LONG
END TYPE

TYPE Statistics
    totalSegments AS LONG
    activeSegments AS LONG
    totalLength AS DOUBLE
    totalJunctions AS LONG
    loopsFound AS LONG
    selectedSegments AS LONG
END TYPE

' Global arrays and variables
CONST MAX_SEGMENTS = 10000
CONST MAX_JUNCTIONS = 5000
CONST MAX_LOOPS = 1000
CONST TOLERANCE = 0.000000001

DIM SHARED lineSegs(1 TO MAX_SEGMENTS) AS LineSeg
DIM SHARED junctions(1 TO MAX_JUNCTIONS) AS Junction
DIM SHARED segmentCount AS LONG
DIM SHARED junctionCount AS LONG
DIM SHARED loopCount AS LONG
DIM SHARED nextRingId AS INTEGER

' Initialize tracer
SUB InitializeTracer
    DIM i AS LONG
    
    segmentCount = 0
    junctionCount = 0
    loopCount = 0
    nextRingId = 1
    
    FOR i = 1 TO MAX_SEGMENTS
        lineSegs(i).active = 0
        lineSegs(i).selected = 0
        lineSegs(i).bad = 0
        lineSegs(i).ringId = 0
        lineSegs(i).pocket = 0
        lineSegs(i).count = 0
        lineSegs(i).Trim1 = 0
        lineSegs(i).Trim2 = 0
    NEXT i
    
    FOR i = 1 TO MAX_JUNCTIONS
        junctions(i).point.x = 0
        junctions(i).point.y = 0
        junctions(i).connectedCount = 0
        junctions(i).degree = 0
    NEXT i
END SUB

' Create a point by modifying it by reference (QB64 workaround)
SUB CreatePoint(x AS DOUBLE, y AS DOUBLE, p AS Point)
    p.x = x
    p.y = y
END SUB

' Calculate segment properties (angle, sine, cosine, distance)
SUB CalculateSegmentProperties(segIndex AS LONG)
    DIM dx AS DOUBLE, dy AS DOUBLE, len AS DOUBLE
    
    dx = lineSegs(segIndex).x2 - lineSegs(segIndex).x1
    dy = lineSegs(segIndex).y2 - lineSegs(segIndex).y1
    
    len = SQR(dx * dx + dy * dy)
    lineSegs(segIndex).Dist = len
    
    IF len > TOLERANCE THEN
        lineSegs(segIndex).Cs = dx / len
        lineSegs(segIndex).Sn = dy / len
        lineSegs(segIndex).Ang = ATN2(dy, dx)
    ELSE
        lineSegs(segIndex).Cs = 0
        lineSegs(segIndex).Sn = 0
        lineSegs(segIndex).Ang = 0
    END IF
END SUB

' ATN2 function (arctangent of y/x)
FUNCTION ATN2(y AS DOUBLE, x AS DOUBLE) AS DOUBLE
    IF x > 0 THEN
        ATN2 = ATN(y / x)
    ELSEIF x < 0 THEN
        IF y >= 0 THEN
            ATN2 = ATN(y / x) + 3.14159265
        ELSE
            ATN2 = ATN(y / x) - 3.14159265
        END IF
    ELSE
        IF y > 0 THEN
            ATN2 = 3.14159265 / 2
        ELSEIF y < 0 THEN
            ATN2 = -3.14159265 / 2
        ELSE
            ATN2 = 0
        END IF
    END IF
END FUNCTION

' Calculate distance between two points (by coordinates)
FUNCTION PointDistance(x1 AS DOUBLE, y1 AS DOUBLE, x2 AS DOUBLE, y2 AS DOUBLE) AS DOUBLE
    DIM dx AS DOUBLE, dy AS DOUBLE
    dx = x1 - x2
    dy = y1 - y2
    PointDistance = SQR(dx * dx + dy * dy)
END FUNCTION

' Check if two points are equal (within tolerance) - by coordinates
FUNCTION PointsEqual(x1 AS DOUBLE, y1 AS DOUBLE, x2 AS DOUBLE, y2 AS DOUBLE) AS LONG
    IF ABS(x1 - x2) < TOLERANCE AND ABS(y1 - y2) < TOLERANCE THEN
        PointsEqual = -1
    ELSE
        PointsEqual = 0
    END IF
END FUNCTION

' Find or create junction for a point (by coordinates)
FUNCTION FindOrCreateJunction(x AS DOUBLE, y AS DOUBLE) AS LONG
    DIM i AS LONG
    
    ' Search for existing junction
    FOR i = 1 TO junctionCount
        IF PointsEqual(junctions(i).point.x, junctions(i).point.y, x, y) THEN
            FindOrCreateJunction = i
            EXIT FUNCTION
        END IF
    NEXT i
    
    ' Create new junction
    IF junctionCount < MAX_JUNCTIONS THEN
        junctionCount = junctionCount + 1
        junctions(junctionCount).point.x = x
        junctions(junctionCount).point.y = y
        junctions(junctionCount).degree = 0
        junctions(junctionCount).connectedCount = 0
        FindOrCreateJunction = junctionCount
    ELSE
        FindOrCreateJunction = -1
    END IF
END FUNCTION

' Add a line segment and mark as active
FUNCTION AddSegment(x1 AS DOUBLE, y1 AS DOUBLE, x2 AS DOUBLE, y2 AS DOUBLE) AS LONG
    DIM startJunc AS LONG, endJunc AS LONG
    
    IF segmentCount >= MAX_SEGMENTS THEN
        AddSegment = -1
        EXIT FUNCTION
    END IF
    
    segmentCount = segmentCount + 1
    
    ' Set coordinates and points
    lineSegs(segmentCount).x1 = x1
    lineSegs(segmentCount).y1 = y1
    lineSegs(segmentCount).x2 = x2
    lineSegs(segmentCount).y2 = y2
    
    ' Set Point types
    lineSegs(segmentCount).p1.x = x1
    lineSegs(segmentCount).p1.y = y1
    lineSegs(segmentCount).p2.x = x2
    lineSegs(segmentCount).p2.y = y2
    
    ' Mark as active
    lineSegs(segmentCount).active = -1
    lineSegs(segmentCount).count = 1
    
    ' Calculate geometric properties
    CalculateSegmentProperties segmentCount
    
    ' Create/find junctions
    startJunc = FindOrCreateJunction(x1, y1)
    endJunc = FindOrCreateJunction(x2, y2)
    
    IF startJunc > 0 AND endJunc > 0 THEN
        junctions(startJunc).degree = junctions(startJunc).degree + 1
        junctions(endJunc).degree = junctions(endJunc).degree + 1
    END IF
    
    AddSegment = segmentCount
END FUNCTION

' Find segment connecting two points by coordinates
FUNCTION FindSegmentByCoords(x1 AS DOUBLE, y1 AS DOUBLE, x2 AS DOUBLE, y2 AS DOUBLE) AS LONG
    DIM i AS LONG
    
    FOR i = 1 TO segmentCount
        IF lineSegs(i).active THEN
            IF (PointsEqual(lineSegs(i).p1.x, lineSegs(i).p1.y, x1, y1) AND _
                PointsEqual(lineSegs(i).p2.x, lineSegs(i).p2.y, x2, y2)) OR _
               (PointsEqual(lineSegs(i).p1.x, lineSegs(i).p1.y, x2, y2) AND _
                PointsEqual(lineSegs(i).p2.x, lineSegs(i).p2.y, x1, y1)) THEN
                FindSegmentByCoords = i
                EXIT FUNCTION
            END IF
        END IF
    NEXT i
    
    FindSegmentByCoords = -1
END FUNCTION

' Mark segment as inactive
SUB DeactivateSegment(segIndex AS LONG)
    IF segIndex >= 1 AND segIndex <= MAX_SEGMENTS THEN
        lineSegs(segIndex).active = 0
    END IF
END SUB

' Mark segment as selected
SUB SelectSegment(segIndex AS LONG)
    IF segIndex >= 1 AND segIndex <= MAX_SEGMENTS AND lineSegs(segIndex).active THEN
        lineSegs(segIndex).selected = -1
    END IF
END SUB

' Deselect segment
SUB DeselectSegment(segIndex AS LONG)
    IF segIndex >= 1 AND segIndex <= MAX_SEGMENTS THEN
        lineSegs(segIndex).selected = 0
    END IF
END SUB

' Mark segment as bad
SUB MarkSegmentBad(segIndex AS LONG)
    IF segIndex >= 1 AND segIndex <= MAX_SEGMENTS AND lineSegs(segIndex).active THEN
        lineSegs(segIndex).bad = -1
    END IF
END SUB

' Assign segment to ring/loop
SUB AssignSegmentToRing(segIndex AS LONG, ringId AS INTEGER)
    IF segIndex >= 1 AND segIndex <= MAX_SEGMENTS AND lineSegs(segIndex).active THEN
        lineSegs(segIndex).ringId = ringId
    END IF
END SUB

' Assign segment to pocket
SUB AssignSegmentToPocket(segIndex AS LONG, pocketId AS INTEGER)
    IF segIndex >= 1 AND segIndex <= MAX_SEGMENTS AND lineSegs(segIndex).active THEN
        lineSegs(segIndex).pocket = pocketId
    END IF
END SUB

' Trim segment
SUB TrimSegment(segIndex AS LONG, trim1 AS DOUBLE, trim2 AS DOUBLE)
    IF segIndex >= 1 AND segIndex <= MAX_SEGMENTS AND lineSegs(segIndex).active THEN
        lineSegs(segIndex).Trim1 = trim1
        lineSegs(segIndex).Trim2 = trim2
    END IF
END SUB

' Find all junctions (degree >= 2)
SUB FindJunctions(juncIndices() AS LONG, count AS LONG)
    DIM i AS LONG
    count = 0
    
    FOR i = 1 TO junctionCount
        IF junctions(i).degree >= 2 THEN
            count = count + 1
            IF count <= UBOUND(juncIndices) THEN
                juncIndices(count) = i
            END IF
        END IF
    NEXT i
END SUB

' Calculate statistics
SUB CalculateStatistics(stats AS Statistics)
    DIM i AS LONG
    DIM activeCount AS LONG, selectedCount AS LONG
    
    stats.totalSegments = segmentCount
    stats.totalJunctions = junctionCount
    stats.loopsFound = loopCount
    stats.totalLength = 0
    activeCount = 0
    selectedCount = 0
    
    FOR i = 1 TO segmentCount
        IF lineSegs(i).active THEN
            stats.totalLength = stats.totalLength + lineSegs(i).Dist
            activeCount = activeCount + 1
        END IF
        
        IF lineSegs(i).selected THEN
            selectedCount = selectedCount + 1
        END IF
    NEXT i
    
    stats.activeSegments = activeCount
    stats.selectedSegments = selectedCount
END SUB

' Print point information (by coordinates)
SUB PrintPoint(x AS DOUBLE, y AS DOUBLE)
    PRINT "Point("; x; ", "; y; ")";
END SUB

' Print segment information
SUB PrintSegment(segIndex AS LONG)
    IF segIndex >= 1 AND segIndex <= MAX_SEGMENTS AND lineSegs(segIndex).active THEN
        PRINT "Segment "; segIndex; ": ("; lineSegs(segIndex).x1; ", "; _
              lineSegs(segIndex).y1; ") -> ("; lineSegs(segIndex).x2; ", "; _
              lineSegs(segIndex).y2; ")";
        PRINT " [Len:"; lineSegs(segIndex).Dist; " Ang:"; lineSegs(segIndex).Ang; "]";
        
        IF lineSegs(segIndex).ringId > 0 THEN
            PRINT " [Ring:"; lineSegs(segIndex).ringId; "]";
        END IF
        
        IF lineSegs(segIndex).selected THEN
            PRINT " [SELECTED]";
        END IF
        
        IF lineSegs(segIndex).bad THEN
            PRINT " [BAD]";
        END IF
        
        PRINT
    END IF
END SUB

' Print junction information
SUB PrintJunction(juncIndex AS LONG)
    IF juncIndex >= 1 AND juncIndex <= junctionCount THEN
        PRINT "Junction(";
        CALL PrintPoint(junctions(juncIndex).point.x, junctions(juncIndex).point.y)
        PRINT ", degree="; junctions(juncIndex).degree; ")";
    END IF
END SUB

' Print all active segments
SUB PrintAllSegments
    DIM i AS LONG
    
    PRINT "=== All Active Segments ==="
    FOR i = 1 TO segmentCount
        IF lineSegs(i).active THEN
            CALL PrintSegment(i)
        END IF
    NEXT i
    PRINT
END SUB

' Print all junctions
SUB PrintAllJunctions
    DIM i AS LONG, juncIndices(MAX_JUNCTIONS) AS LONG, count AS LONG
    
    PRINT "=== All Junctions ==="
    CALL FindJunctions(juncIndices(), count)
    
    FOR i = 1 TO count
        CALL PrintJunction(juncIndices(i))
        PRINT
    NEXT i
END SUB

' Print statistics
SUB PrintStatistics
    DIM stats AS Statistics
    
    CALL CalculateStatistics(stats)
    
    PRINT "=== Statistics ==="
    PRINT "Total Segments: "; stats.totalSegments
    PRINT "Active Segments: "; stats.activeSegments
    PRINT "Selected Segments: "; stats.selectedSegments
    PRINT "Total Length: "; stats.totalLength
    PRINT "Total Junctions: "; stats.totalJunctions
    PRINT "Loops Found: "; stats.loopsFound
    PRINT
END SUB

' Trace a polyline from starting segment, marking connected segments
SUB TracePolyline(startSegIndex AS LONG, pathSegments() AS LONG, pathCount AS LONG)
    DIM visited(MAX_SEGMENTS) AS LONG
    DIM currentX1 AS DOUBLE, currentY1 AS DOUBLE
    DIM currentX2 AS DOUBLE, currentY2 AS DOUBLE
    DIM nextSegIndex AS LONG, i AS LONG, j AS LONG
    
    pathCount = 0
    FOR i = 1 TO MAX_SEGMENTS
        visited(i) = 0
        pathSegments(i) = 0
    NEXT i
    
    IF startSegIndex < 1 OR startSegIndex > MAX_SEGMENTS THEN EXIT SUB
    IF NOT lineSegs(startSegIndex).active THEN EXIT SUB
    
    ' Start from first segment
    pathCount = 1
    pathSegments(1) = startSegIndex
    visited(startSegIndex) = -1
    
    currentX2 = lineSegs(startSegIndex).x2
    currentY2 = lineSegs(startSegIndex).y2
    
    ' Continue tracing
    DO
        DIM foundNext AS LONG
        foundNext = 0
        
        FOR i = 1 TO segmentCount
            IF lineSegs(i).active AND visited(i) = 0 THEN
                ' Check if this segment connects
                IF ABS(lineSegs(i).x1 - currentX2) < TOLERANCE AND _
                   ABS(lineSegs(i).y1 - currentY2) < TOLERANCE THEN
                    pathCount = pathCount + 1
                    IF pathCount <= UBOUND(pathSegments) THEN
                        pathSegments(pathCount) = i
                    END IF
                    visited(i) = -1
                    currentX2 = lineSegs(i).x2
                    currentY2 = lineSegs(i).y2
                    foundNext = -1
                    EXIT FOR
                ELSEIF ABS(lineSegs(i).x2 - currentX2) < TOLERANCE AND _
                       ABS(lineSegs(i).y2 - currentY2) < TOLERANCE THEN
                    pathCount = pathCount + 1
                    IF pathCount <= UBOUND(pathSegments) THEN
                        pathSegments(pathCount) = i
                    END IF
                    visited(i) = -1
                    currentX2 = lineSegs(i).x1
                    currentY2 = lineSegs(i).y1
                    foundNext = -1
                    EXIT FOR
                END IF
            END IF
        NEXT i
        
        IF NOT foundNext THEN EXIT DO
    LOOP
END SUB

' Mark a loop by assigning segments to a ringId
SUB MarkLoop(pathSegments() AS LONG, pathCount AS LONG)
    DIM i AS LONG, ringId AS INTEGER
    
    loopCount = loopCount + 1
    ringId = nextRingId
    nextRingId = nextRingId + 1
    
    FOR i = 1 TO pathCount
        IF pathSegments(i) > 0 THEN
            CALL AssignSegmentToRing(pathSegments(i), ringId)
        END IF
    NEXT i
END SUB

' Find segments by ring ID
SUB FindSegmentsByRing(ringId AS INTEGER, segIndices() AS LONG, count AS LONG)
    DIM i AS LONG
    count = 0
    
    FOR i = 1 TO segmentCount
        IF lineSegs(i).active AND lineSegs(i).ringId = ringId THEN
            count = count + 1
            IF count <= UBOUND(segIndices) THEN
                segIndices(count) = i
            END IF
        END IF
    NEXT i
END SUB

' Find segments by pocket ID
SUB FindSegmentsByPocket(pocketId AS INTEGER, segIndices() AS LONG, count AS LONG)
    DIM i AS LONG
    count = 0
    
    FOR i = 1 TO segmentCount
        IF lineSegs(i).active AND lineSegs(i).pocket = pocketId THEN
            count = count + 1
            IF count <= UBOUND(segIndices) THEN
                segIndices(count) = i
            END IF
        END IF
    NEXT i
END SUB

' Get count of active segments
FUNCTION CountActiveSegments AS LONG
    DIM i AS LONG, count AS LONG
    count = 0
    
    FOR i = 1 TO segmentCount
        IF lineSegs(i).active THEN
            count = count + 1
        END IF
    NEXT i
    
    CountActiveSegments = count
END FUNCTION

' Get count of selected segments
FUNCTION CountSelectedSegments AS LONG
    DIM i AS LONG, count AS LONG
    count = 0
    
    FOR i = 1 TO segmentCount
        IF lineSegs(i).selected THEN
            count = count + 1
        END IF
    NEXT i
    
    CountSelectedSegments = count
END FUNCTION
