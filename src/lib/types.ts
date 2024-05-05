export enum Tabs {
    None,
    Map,
    Sensors,
    Options
}

export type Image = [number, number, number, number][][];
export type BinaryImage = number[][];
export type AStarPath = [number, number][];
export type AStarHeuristics = 'Manhattan' | 'Euclidean' | 'Chebyshev' | 'Octile';
