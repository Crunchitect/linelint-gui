export enum Tabs {
    None,
    Map,
    Sensors
}

export type Image = [number, number, number, number][][];
export type BinaryImage = number[][];
export type AStarPath = [number, number][];