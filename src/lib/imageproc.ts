//@ts-ignore
import * as thinning_wasm from "./wasm/thinning.wasm";
import type { Image, BinaryImage } from '@/lib/types';

export function reshape_bytes(im: Uint8ClampedArray, width: number, height: number) {
    const image = [] as Image;
    for (let y = 0; y < height; y++) {
        image.push([]);
        for (let x = 0; x < width; x++) {
            // @ts-ignore: Populate Later
            image[y].push([]);
            for (let c = 0; c < 4; c++) {
                image[y][x].push(im[y * width * 4 + x * 4 + c]);
            }
        }
    }
    return image;
}

export function to_binary_image(im: Image) {
    return im.map(row => 
        row.map( pixel =>
            Number((pixel.reduce((a, b) => a + b) / 4) > 127)
        )
    );
}

export function bitwise_not(im: BinaryImage) {
    return im.map(row =>
        row.map(pixel => 
            Number(!pixel)
        )
    );
}

export function _thinning_js(im: BinaryImage) {
    // https://rosettacode.org/wiki/Zhang-Suen_thinning_algorithm
    // https://dl.acm.org/doi/pdf/10.1145/357994.358023
    function get_neighbours(im: BinaryImage, x: number, y: number) {
        return [
            im[y-1][x] ?? 0,
            im[y-1][x+1] ?? 0,
            im[y][x+1] ?? 0,
            im[y+1][x+1] ?? 0,
            im[y+1][x] ?? 0,
            im[y+1][x-1] ?? 0,
            im[y][x-1] ?? 0,
            im[y-1][x-1] ?? 0,
        ];
    }

    function cond_a(im: BinaryImage, x: number, y: number) {
        const neighbours = get_neighbours(im, x, y);
        neighbours.push(neighbours[0])
        return (neighbours.map(pixel => String(pixel)).join().match(/01/g) || []).length == 1;
    }

    function cond_b(im: BinaryImage, x: number, y: number) {
        const neighbours = get_neighbours(im, x, y);
        const sum = neighbours.reduce((a, b) => a + b);
        return 2 <= sum && sum <= 6
    }

    function cond_c(im: BinaryImage, x: number, y: number, is_step_one: boolean) {
        const neighbours = get_neighbours(im, x, y);
        if (is_step_one)
            return neighbours[0] && neighbours[2] && neighbours[4] == 0;
        else
            return neighbours[2] && neighbours[4] && neighbours[6] == 0;
    }

    function cond_d(im: BinaryImage, x: number, y: number, is_step_one: boolean) {
        const neighbours = get_neighbours(im, x, y);
        if (is_step_one)
            return neighbours[0] && neighbours[2] && neighbours[6] == 0;
        else
            return neighbours[0] && neighbours[4] && neighbours[6] == 0;
    }

    let step_one = true;
    let old_im = im;
    let new_im: null | BinaryImage = null;
    while (old_im != new_im) {
        console.log(step_one)
        new_im = old_im.map((row, y) =>
            row.map((pixel, x) => {
                if (!pixel) return 0;
                if (
                    cond_a(im, x, y) && 
                    cond_b(im, x, y) && 
                    cond_c(im, x, y, step_one) && 
                    cond_d(im, x, y, step_one)) return 0;
                else return 1;
            }
            )
        );
        step_one = !step_one;
    }
    return new_im;
}

export async function thinning(im: BinaryImage) {
    const [image_width, image_height] = [im[0].length, im.length];
    im.forEach((row, y) =>
        row.forEach((pixel, x) => 
            thinning_wasm.set_pixel(image_width, x, y, pixel)
        )
    );
    thinning_wasm.thinning_zs(image_width, image_height);
    thinning_wasm.corner_fixing(image_width, image_height);
    return im.map((row, y) =>
        row.map((_, x) => 
            thinning_wasm.get_pixel(image_width, x, y)
        )
    );

}

export async function get_closest_black_pixel(im: BinaryImage, x: number, y: number) {
    let sum = 0;
    while (true) {
        for (let dx = 0; dx <= sum; dx++) {
            let dy = sum - dx;
            for (const sign of [[1, 1], [-1, 1], [1, -1], [-1, -1]]) {
                if (im[y + dy * sign[1]][x + dx * sign[0]] == 0)
                    return [x + dx * sign[0], y + dy * sign[1]];
            }
        }
        sum++;
    }
}

export async function skeletonize(im: Uint8ClampedArray, width: number, height: number) {
    const image = reshape_bytes(im, width, height);
    const flatten = bitwise_not(to_binary_image(image));
    const thinned = bitwise_not(await thinning(flatten));
    // console.log(thinned);

    return thinned;
    
    // console.log(flatten[181][60], flatten[60][181]);
}

