' Junction Example - QB64 Basic
' Creates a T-shaped structure with junction points

'$INCLUDE: 'line_segment_tracer.bas'

PROGRAM Example_Junction

DIM juncIndices(MAX_JUNCTIONS) AS LONG
DIM juncCount AS LONG
DIM stats AS Statistics

' Initialize the tracer
CALL InitializeTracer

PRINT "=== T-Shaped Junction Example ==="
PRINT

' Create a T-shaped structure
' Horizontal line: (0, 0) -> (2, 0)
CALL AddSegment(0, 0, 1, 0)
CALL AddSegment(1, 0, 2, 0)

' Vertical line from junction: (1, 0) -> (1, 2)
CALL AddSegment(1, 0, 1, 1)
CALL AddSegment(1, 1, 1, 2)

PRINT "Added 4 segments forming a T-shape"
PRINT "Junction at (1, 0) with degree 3 (one up, one left, one right)"
PRINT

' Print all segments
CALL PrintAllSegments

' Find and print junctions with degree >= 2
CALL FindJunctions(juncIndices(), juncCount)

PRINT "Found "; juncCount; " junction(s):"
DIM i AS LONG
FOR i = 1 TO juncCount
    PRINT "  ";
    CALL PrintJunction(juncIndices(i))
    PRINT
NEXT i
PRINT

' Select some segments
CALL SelectSegment(1)
CALL SelectSegment(3)

PRINT "Selected segments 1 and 3"
PRINT

' Mark segment 2 as bad
CALL MarkSegmentBad(2)

PRINT "Marked segment 2 as bad"
PRINT

' Print statistics
CALL PrintStatistics

' Assign segments to pockets
CALL AssignSegmentToPocket(1, 1)
CALL AssignSegmentToPocket(2, 1)
CALL AssignSegmentToPocket(3, 2)
CALL AssignSegmentToPocket(4, 2)

PRINT "Assigned segments to pockets:"
PRINT "  Segments 1, 2 -> Pocket 1"
PRINT "  Segments 3, 4 -> Pocket 2"
PRINT

' Find segments by pocket
DIM pocketSegments(MAX_SEGMENTS) AS LONG
DIM pocketCount AS LONG

CALL FindSegmentsByPocket(1, pocketSegments(), pocketCount)
PRINT "Segments in Pocket 1: ";
FOR i = 1 TO pocketCount
    PRINT pocketSegments(i); " ";
NEXT i
PRINT

CALL FindSegmentsByPocket(2, pocketSegments(), pocketCount)
PRINT "Segments in Pocket 2: ";
FOR i = 1 TO pocketCount
    PRINT pocketSegments(i); " ";
NEXT i
PRINT

END PROGRAM
