import type { BinaryImage, AStarPath } from "./types";
import { slidingWindow } from "./polyfill";

type Vec2D = [number, number];

function get_diff(v1: Vec2D, v2: Vec2D) {
    return <Vec2D>[v2[0] - v1[0], v2[1] - v1[1]];
}

function dot_product(v1: Vec2D, v2: Vec2D) {
    return v1[0] * v2[0] + v1[1] * v2[1];
}

function determinant(v1: Vec2D, v2: Vec2D) {
    return v1[0] * v2[1] - v1[1] * v2[0];
}

export function detect_junctions(im: BinaryImage, path: AStarPath) {
    let path_str = '';
    let junction_point = null as null | [number, number];
    slidingWindow(path, 4).forEach((val) => {
        junction_point = null;
        const u = get_diff(val[1], val[0]);
        const v = get_diff(val[2], val[1]);
        const w = get_diff(val[3], val[2]);

        const dot_vw = dot_product(v, w);
        const det_vw = determinant(v, w);
        const angle_vw = Math.atan2(det_vw, dot_vw) / Math.PI * 180;

        const dot_uw = dot_product(u, w);
        const det_uw = determinant(u, w);
        const angle_uw = Math.atan2(det_uw, dot_uw) / Math.PI * 180;

        if (angle_vw == -90 || angle_vw == 90) {
            junction_point = val[1];
        } else if (angle_vw == -45 || angle_vw == 45) {
            junction_point = [
                val[0][0] + (2 * u[0]),
                val[0][1] + (2 * u[1]),
            ]
        }

        if (angle_uw == 0)   {path_str += 'f';}
        else if (angle_uw == -90) {path_str += 'l';}
        else if (angle_uw == 90)  {path_str += 'r';}
    });
    path_str = path_str.replace(/f+/g, 'f');
    console.log(path_str);
}