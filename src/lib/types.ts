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

export type NLengthArray<T, N extends number> = number extends N ? T[] : NLengthArrayConstructor<T, N, []>;
type NLengthArrayConstructor<T, N extends number, O extends T[]> = O['length'] extends N ? O : NLengthArrayConstructor<T, N, [...O, T]>;
