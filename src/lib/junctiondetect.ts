import type { BinaryImage, AStarPath } from "./types";
import { slidingWindow } from "./polyfill";
import { ref } from "vue";

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

export const junction_types = ref({
    leftTack: [0, 0, 0, 1, 1],
    rightTack: [1, 1, 0, 0, 0],
    cross: [0, 0, 0, 0, 0],
});

export const sensor_offsets = ref([
    [-2, 0],
    [-1, 0],
    [0, 0],
    [1, 0],
    [2, 0]
]);

export function get_junction(im: BinaryImage, point: Vec2D, dir: Vec2D) {
  const sensor_check = [-dir[1], dir[0]];
  const sensors = [
    im[point[1] + 2*sensor_check[1]][point[0] + 2*sensor_check[0]],
    im[point[1] + 1*sensor_check[1]][point[0] + 1*sensor_check[0]],
    im[point[1] + 0*sensor_check[1]][point[0] + 0*sensor_check[0]],
    im[point[1] - 1*sensor_check[1]][point[0] - 1*sensor_check[0]],
    im[point[1] - 2*sensor_check[1]][point[0] - 2*sensor_check[0]],
  ];
  for (const name in junction_types.value) {
    const junction_arr = (<{[k:string]: number[]}>junction_types.value)[name];
    const is_junction = junction_arr.every((v, i) => v === sensors[i]);
    if (is_junction) return name;
  }
}

export function detect_junctions(im: BinaryImage, path: AStarPath) {
    let path_str = "";
    let junction_point = null as null | [number, number];
    let is_junction = null as null | string;
    slidingWindow(path, 4).forEach((val) => {
        junction_point = null;
        const u = get_diff(val[1], val[0]);
        const w = get_diff(val[3], val[2]);

        const dot_uw = dot_product(u, w);
        const det_uw = determinant(u, w);
        const angle_uw = (Math.atan2(det_uw, dot_uw) / Math.PI) * 180;

        junction_point = val[1];
        const junction_case1 = get_junction(im, junction_point, u);
        if (junction_case1) {
          console.log(u, w, angle_uw, val)
          if (angle_uw === 0) path_str += `(${junction_case1}, forward)`;
          else if (angle_uw === -90) path_str += `(${junction_case1}, left)`;
          else if (angle_uw === 90) path_str += `(${junction_case1}, right)`;
          return;
        }
        junction_point = [val[0][0] + 2 * u[0], val[0][1] + 2 * u[1]];
        const junction_case2 = get_junction(im, junction_point, u);
        if (junction_case2) {
          console.log(val[2])
          if (angle_uw === 0) path_str += `(${junction_case2}, forward)`;
          else if (angle_uw === -90) path_str += `(${junction_case2}, left)`;
          else if (angle_uw === 90) path_str += `(${junction_case2}, right)`;
          return;
        }
        path_str += '-';
    });
    path_str = path_str.replace(/-+/g, "-");
    console.log(path_str);
}
