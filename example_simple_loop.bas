' Simple Loop Example - QB64 Basic
' Creates a square loop and traces it

'$INCLUDE: 'line_segment_tracer.bas'

PROGRAM Example_SimpleLoop

DIM pathSegments(MAX_SEGMENTS) AS LONG
DIM pathCount AS LONG
DIM stats AS Statistics

' Initialize the tracer
CALL InitializeTracer

PRINT "=== Simple Square Loop Example ==="
PRINT

' Create a square loop with 4 segments
' Segment 1: (0, 0) -> (1, 0)
CALL AddSegment(0, 0, 1, 0)

' Segment 2: (1, 0) -> (1, 1)
CALL AddSegment(1, 0, 1, 1)

' Segment 3: (1, 1) -> (0, 1)
CALL AddSegment(1, 1, 0, 1)

' Segment 4: (0, 1) -> (0, 0) - closes the loop
CALL AddSegment(0, 1, 0, 0)

PRINT "Added 4 segments forming a square loop"
PRINT

' Print all segments
CALL PrintAllSegments

' Find and print junctions
CALL PrintAllJunctions

' Trace polyline starting from segment 1
CALL TracePolyline(1, pathSegments(), pathCount)

PRINT "Traced polyline with "; pathCount; " segments:"
DIM i AS LONG
FOR i = 1 TO pathCount
    PRINT "  Segment "; pathSegments(i);
    IF i < pathCount THEN PRINT ", "; ELSE PRINT
NEXT i
PRINT

' Mark the loop
CALL MarkLoop(pathSegments(), pathCount)

' Print statistics
CALL PrintStatistics

PRINT "Loop marked with ringId = 1"
PRINT

' Find and display segments in ring 1
DIM ringSegments(MAX_SEGMENTS) AS LONG
DIM ringCount AS LONG
CALL FindSegmentsByRing(1, ringSegments(), ringCount)

PRINT "Segments in Ring 1:"
FOR i = 1 TO ringCount
    PRINT "  "; ringSegments(i);
NEXT i
PRINT

END PROGRAM
