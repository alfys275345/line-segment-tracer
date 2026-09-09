' Complex Polyline Example - QB64 Basic
' Creates an irregular hexagonal polyline with loops

'$INCLUDE: 'line_segment_tracer.bas'

PROGRAM Example_ComplexPolyline

DIM pathSegments(MAX_SEGMENTS) AS LONG
DIM pathCount AS LONG
DIM stats AS Statistics
DIM ringSegments(MAX_SEGMENTS) AS LONG
DIM ringCount AS LONG

' Initialize the tracer
CALL InitializeTracer

PRINT "=== Complex Hexagonal Polyline Example ==="
PRINT

' Create an irregular hexagon
' Point 1: (0, 0)
' Point 2: (2, 0)
CALL AddSegment(0, 0, 2, 0)

' Point 3: (3, 1)
CALL AddSegment(2, 0, 3, 1)

' Point 4: (2, 2)
CALL AddSegment(3, 1, 2, 2)

' Point 5: (0, 2)
CALL AddSegment(2, 2, 0, 2)

' Point 6: (-1, 1)
CALL AddSegment(0, 2, -1, 1)

' Back to Point 1: (0, 0) - closes the loop
CALL AddSegment(-1, 1, 0, 0)

PRINT "Added 6 segments forming a closed hexagon"
PRINT

' Print all segments
CALL PrintAllSegments

' Find and print junctions
PRINT "All junction points:"
DIM i AS LONG, j AS LONG
DIM juncIndices(MAX_JUNCTIONS) AS LONG
DIM juncCount AS LONG
CALL FindJunctions(juncIndices(), juncCount)

FOR i = 1 TO juncCount
    PRINT "  ";
    CALL PrintJunction(juncIndices(i))
    PRINT
NEXT i
PRINT

' Trace the polyline starting from segment 1
CALL TracePolyline(1, pathSegments(), pathCount)

PRINT "Traced complete polyline with "; pathCount; " segments:"
FOR i = 1 TO pathCount
    PRINT "  Segment "; pathSegments(i);
    IF i < pathCount THEN PRINT " -> "; ELSE PRINT
NEXT i
PRINT

' Mark as a loop (ring)
CALL MarkLoop(pathSegments(), pathCount)

PRINT "Marked as Ring 1"
PRINT

' Demonstrate segment trimming
PRINT "Trimming segment 1 from 0.2 to 0.8 of its length"
CALL TrimSegment(1, 0.2, 0.8)

PRINT "Trimming segment 3 from 0.1 to 0.9 of its length"
CALL TrimSegment(3, 0.1, 0.9)
PRINT

' Print statistics
CALL PrintStatistics

' Show segment details including angles and distances
PRINT "Detailed segment information:"
FOR i = 1 TO segmentCount
    IF lineSegs(i).active THEN
        PRINT "Segment "; i; ": "
        PRINT "  Length: "; lineSegs(i).Dist
        PRINT "  Angle: "; lineSegs(i).Ang; " radians"
        PRINT "  Sine: "; lineSegs(i).Sn; ", Cosine: "; lineSegs(i).Cs
        IF lineSegs(i).ringId > 0 THEN
            PRINT "  Ring ID: "; lineSegs(i).ringId
        END IF
        IF lineSegs(i).Trim1 <> 0 OR lineSegs(i).Trim2 <> 0 THEN
            PRINT "  Trim Range: "; lineSegs(i).Trim1; " to "; lineSegs(i).Trim2
        END IF
        PRINT
    END IF
NEXT i

' Find segments by ring
CALL FindSegmentsByRing(1, ringSegments(), ringCount)

PRINT "Total segments in Ring 1: "; ringCount
PRINT "Segments: ";
FOR i = 1 TO ringCount
    PRINT ringSegments(i); " ";
NEXT i
PRINT

' Count active and selected segments
PRINT
PRINT "Active Segments: "; CountActiveSegments()
PRINT "Selected Segments: "; CountSelectedSegments()
PRINT

END PROGRAM
