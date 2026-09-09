' Line Segment Tracer - QB64 Basic Variant
' A library for tracing line segments, identifying junctions, and detecting loops

' Type definitions
TYPE Point
    x AS DOUBLE
    y AS DOUBLE
END TYPE

TYPE LineSegment
    startPoint AS Point
    endPoint AS Point
    segmentID AS LONG
END TYPE

TYPE Junction
    point AS Point
    connectedCount AS LONG
    degree AS LONG
END TYPE

TYPE Statistics
    totalSegments AS LONG
    totalLength AS DOUBLE
    totalJunctions AS LONG
    loopsFound AS LONG
END TYPE

' Global arrays and variables
CONST MAX_SEGMENTS = 10000
CONST MAX_JUNCTIONS = 5000
CONST MAX_LOOPS = 1000
CONST TOLERANCE = 0.000000001

DIM SHARED segments(1 TO MAX_SEGMENTS) AS LineSegment
DIM SHARED junctions(1 TO MAX_JUNCTIONS) AS Junction
DIM SHARED loops(1 TO MAX_LOOPS, 1 TO MAX_SEGMENTS) AS LONG ' Array of loop paths
DIM SHARED loopSizes(1 TO MAX_LOOPS) AS LONG ' Size of each loop
DIM SHARED segmentCount AS LONG
DIM SHARED junctionCount AS LONG
DIM SHARED loopCount AS LONG
DIM SHARED adjacencyList(1 TO MAX_JUNCTIONS, 1 TO MAX_JUNCTIONS) AS LONG
DIM SHARED adjacencySize(1 TO MAX_JUNCTIONS) AS LONG

' Initialize tracer
SUB InitializeTracer
    segmentCount = 0
    junctionCount = 0
    loopCount = 0
    
    DIM i AS LONG
    FOR i = 1 TO MAX_JUNCTIONS
        adjacencySize(i) = 0
    NEXT i
    
    FOR i = 1 TO MAX_LOOPS
        loopSizes(i) = 0
    NEXT i
END SUB

' Create a point
FUNCTION CreatePoint(x AS DOUBLE, y AS DOUBLE) AS Point
    DIM p AS Point
    p.x = x
    p.y = y
    CreatePoint = p
END FUNCTION

' Calculate distance between two points
FUNCTION PointDistance(p1 AS Point, p2 AS Point) AS DOUBLE
    DIM dx AS DOUBLE, dy AS DOUBLE
    dx = p1.x - p2.x
    dy = p1.y - p2.y
    PointDistance = SQR(dx * dx + dy * dy)
END FUNCTION

' Check if two points are equal (within tolerance)
FUNCTION PointsEqual(p1 AS Point, p2 AS Point) AS LONG
    IF ABS(p1.x - p2.x) < TOLERANCE AND ABS(p1.y - p2.y) < TOLERANCE THEN
        PointsEqual = -1
    ELSE
        PointsEqual = 0
    END IF
END FUNCTION

' Find or create junction for a point
FUNCTION FindOrCreateJunction(p AS Point) AS LONG
    DIM i AS LONG
    
    ' Search for existing junction
    FOR i = 1 TO junctionCount
        IF PointsEqual(junctions(i).point, p) THEN
            FindOrCreateJunction = i
            EXIT FUNCTION
        END IF
    NEXT i
    
    ' Create new junction
    IF junctionCount < MAX_JUNCTIONS THEN
        junctionCount = junctionCount + 1
        junctions(junctionCount).point = p
        junctions(junctionCount).degree = 0
        junctions(junctionCount).connectedCount = 0
        FindOrCreateJunction = junctionCount
    ELSE
        FindOrCreateJunction = -1
    END IF
END FUNCTION

' Add a line segment
FUNCTION AddSegment(startPoint AS Point, endPoint AS Point, segID AS LONG) AS LONG
    IF segmentCount >= MAX_SEGMENTS THEN
        AddSegment = -1
        EXIT FUNCTION
    END IF
    
    segmentCount = segmentCount + 1
    segments(segmentCount).startPoint = startPoint
    segments(segmentCount).endPoint = endPoint
    segments(segmentCount).segmentID = segID
    
    DIM startJunc AS LONG, endJunc AS LONG
    startJunc = FindOrCreateJunction(startPoint)
    endJunc = FindOrCreateJunction(endPoint)
    
    IF startJunc > 0 AND endJunc > 0 THEN
        junctions(startJunc).degree = junctions(startJunc).degree + 1
        junctions(endJunc).degree = junctions(endJunc).degree + 1
        
        ' Add to adjacency list
        IF adjacencySize(startJunc) < MAX_JUNCTIONS THEN
            adjacencySize(startJunc) = adjacencySize(startJunc) + 1
            adjacencyList(startJunc, adjacencySize(startJunc)) = endJunc
        END IF
        
        IF adjacencySize(endJunc) < MAX_JUNCTIONS THEN
            adjacencySize(endJunc) = adjacencySize(endJunc) + 1
            adjacencyList(endJunc, adjacencySize(endJunc)) = startJunc
        END IF
    END IF
    
    AddSegment = segmentCount
END FUNCTION

' Find segment connecting two points
FUNCTION FindSegment(p1 AS Point, p2 AS Point) AS LONG
    DIM i AS LONG
    
    FOR i = 1 TO segmentCount
        IF (PointsEqual(segments(i).startPoint, p1) AND PointsEqual(segments(i).endPoint, p2)) OR _
           (PointsEqual(segments(i).startPoint, p2) AND PointsEqual(segments(i).endPoint, p1)) THEN
            FindSegment = i
            EXIT FUNCTION
        END IF
    NEXT i
    
    FindSegment = -1
END FUNCTION

' Calculate segment length
FUNCTION SegmentLength(segIndex AS LONG) AS DOUBLE
    SegmentLength = PointDistance(segments(segIndex).startPoint, segments(segIndex).endPoint)
END FUNCTION

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
    
    stats.totalSegments = segmentCount
    stats.totalJunctions = junctionCount
    stats.loopsFound = loopCount
    stats.totalLength = 0
    
    FOR i = 1 TO segmentCount
        stats.totalLength = stats.totalLength + SegmentLength(i)
    NEXT i
END SUB

' Print point information
SUB PrintPoint(p AS Point)
    PRINT "Point("; p.x; ", "; p.y; ")";
END SUB

' Print segment information
SUB PrintSegment(segIndex AS LONG)
    PRINT "Segment "; segIndex; ": ";
    PrintPoint segments(segIndex).startPoint
    PRINT " -> ";
    PrintPoint segments(segIndex).endPoint
END SUB

' Print junction information
SUB PrintJunction(juncIndex AS LONG)
    PRINT "Junction(";
    PrintPoint junctions(juncIndex).point
    PRINT ", degree="; junctions(juncIndex).degree; ")";
END SUB

' Print all segments
SUB PrintAllSegments
    DIM i AS LONG
    
    PRINT "=== All Segments ==="
    FOR i = 1 TO segmentCount
        PrintSegment i
    NEXT i
    PRINT
END SUB

' Print all junctions
SUB PrintAllJunctions
    DIM i AS LONG, juncIndices(MAX_JUNCTIONS) AS LONG, count AS LONG
    
    PRINT "=== All Junctions ==="
    FindJunctions juncIndices(), count
    
    FOR i = 1 TO count
        PrintJunction juncIndices(i)
        PRINT
    NEXT i
END SUB

' Print statistics
SUB PrintStatistics
    DIM stats AS Statistics
    
    CalculateStatistics stats
    
    PRINT "=== Statistics ==="
    PRINT "Total Segments: "; stats.totalSegments
    PRINT "Total Length: "; stats.totalLength
    PRINT "Total Junctions: "; stats.totalJunctions
    PRINT "Loops Found: "; stats.loopsFound
    PRINT
END SUB

' Trace a polyline from starting point
SUB TracePolyline(startPoint AS Point, pathSegments() AS LONG, pathCount AS LONG)
    DIM visited(MAX_SEGMENTS) AS LONG
    DIM currentJunc AS LONG, nextJunc AS LONG, segIndex AS LONG, i AS LONG, j AS LONG
    
    pathCount = 0
    FOR i = 1 TO MAX_SEGMENTS
        visited(i) = 0
        pathSegments(i) = 0
    NEXT i
    
    currentJunc = FindOrCreateJunction(startPoint)
    IF currentJunc < 0 THEN EXIT SUB
    
    DO
        DIM foundNext AS LONG
        foundNext = 0
        
        FOR i = 1 TO adjacencySize(currentJunc)
            nextJunc = adjacencyList(currentJunc, i)
            segIndex = FindSegment(junctions(currentJunc).point, junctions(nextJunc).point)
            
            IF segIndex > 0 AND visited(segIndex) = 0 THEN
                pathCount = pathCount + 1
                IF pathCount <= UBOUND(pathSegments) THEN
                    pathSegments(pathCount) = segIndex
                END IF
                visited(segIndex) = -1
                currentJunc = nextJunc
                foundNext = -1
                EXIT FOR
            END IF
        NEXT i
        
        IF NOT foundNext THEN EXIT DO
    LOOP
END SUB

' Simple loop detection (basic version)
SUB FindSimpleLoops
    DIM i AS LONG, startJunc AS LONG, juncIndices(MAX_JUNCTIONS) AS LONG, count AS LONG
    
    ' For a simple implementation, we'll just report junctions as potential loop points
    ' A full loop detection would require more complex DFS algorithm
    
    FindJunctions juncIndices(), count
    
    PRINT "=== Potential Loop Points ==="
    FOR i = 1 TO count
        PRINT "Junction with degree "; junctions(juncIndices(i)).degree; " at ";
        PrintPoint junctions(juncIndices(i)).point
        PRINT
    NEXT i
END SUB
