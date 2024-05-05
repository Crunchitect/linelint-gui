<script setup lang="ts">
import Draggable from './RobotMap/Draggable.vue';
import { skeletonize, get_closest_black_pixel } from '@/lib/imageproc';
import { ref, watchEffect, onUpdated } from 'vue';
import { clamp } from '@vueuse/core';
import { useElementBounding } from '@vueuse/core';
import { AStarFinder } from 'astar-typescript';
import { heuristic } from '@/config/pathfind';
import type { AStarPath, BinaryImage } from '@/lib/types';


const map_canvas = ref(document.createElement('canvas'));
const path_canvas = ref(document.createElement('canvas'));

const canvas = ref(null as null | HTMLCanvasElement);

const canvas_bounds = ref(useElementBounding(canvas));
const hasPicture = ref(false);
const start = ref([0, 0]);
const end = ref([0, 0]);

const width = ref(0);
const height = ref(0);

const updateFile = (e: Event) => {
    hasPicture.value = true;
    const input = (<Event & {target: HTMLInputElement}>e).target;
    const file = input.files?.[0];
    const image = new Image();
    const reader = new FileReader();
    const context = map_canvas?.value?.getContext("2d", { willReadFrequently: true });
    reader.readAsDataURL(file!);
    reader.onload = e => {
        if (e.target?.readyState == FileReader.DONE) {
            image.src = <string>e.target.result;
            image.onload = () => {
                context!.canvas.width = image.width;
                context!.canvas.height = image.height;
                width.value = image.width;
                height.value = image.height;
                context!.drawImage(image, 0, 0);
            }
        }
    };
};

const findPath = async (thinned_image: BinaryImage) => {
    const start_pos = await get_closest_black_pixel(thinned_image, Math.round(start.value[0]), Math.round(start.value[1]));
    const end_pos = await get_closest_black_pixel(thinned_image, Math.round(end.value[0]), Math.round(end.value[1]));

    const astar_instance = new AStarFinder({
        grid: {
            matrix: thinned_image
        },
        heuristic: heuristic.value
    });
    const path = astar_instance.findPath({x: start_pos[0], y: start_pos[1]}, {x: end_pos[0], y: end_pos[1]});
    return path;
};

const drawPath = (path: AStarPath) => {
    const ctx = path_canvas.value.getContext("2d")!;
    ctx.canvas.width = width.value;
    ctx.canvas.height = height.value;

    ctx.fillStyle = "#0ea5e9";
    path.forEach(point => {
        ctx.fillRect(point[0], point[1], 10, 10);
    })
};

const processImage = async () => {
    const context = map_canvas?.value?.getContext("2d", { willReadFrequently: true });
    const empty_image = new ImageData(new Uint8ClampedArray([0, 0, 0, 0]), 1, 1);
    const { data, width, height } = context?.getImageData(0, 0, context.canvas.width, context.canvas.height) ?? empty_image;
    const thinned_image = await skeletonize(data, width, height);
    // thinned_image.forEach((row, y) => row.forEach((pixel, x) => {
    //     context?.putImageData(new ImageData(new Uint8ClampedArray([pixel * 255, pixel * 255, pixel * 255, 255]), 1, 1), x, y)
    // }))
    // console.log("THINNED")
    const path = await findPath(thinned_image);
    drawPath(<AStarPath>path);
    draw();
};

const updateStart = (pos: [number, number]) => {
    const { left, right, top, bottom, width, height } = canvas.value?.getBoundingClientRect() ?? new DOMRect();
    const ctx = map_canvas.value?.getContext("2d", { willReadFrequently: true });
    const clamped_x = clamp(pos[0], left, right) - left;
    const clamped_y = clamp(pos[1], top, bottom) - top;
    start.value = [clamped_x / width * ctx!.canvas.width, clamped_y / height * ctx!.canvas.height];
};

const updateEnd = (pos: [number, number]) => {
    const { left, right, top, bottom, width, height } = canvas.value?.getBoundingClientRect() ?? new DOMRect();
    const ctx = map_canvas.value?.getContext("2d", { willReadFrequently: true });
    const clamped_x = clamp(pos[0], left, right) - left;
    const clamped_y = clamp(pos[1], top, bottom) - top;
    end.value = [clamped_x / width * ctx!.canvas.width, clamped_y / height * ctx!.canvas.height];
};

const draw = () => {
    const ctx = canvas.value?.getContext("2d");
    if (!ctx) return;
    ctx.canvas.width = width.value;
    ctx.canvas.height = height.value;
    ctx?.drawImage(map_canvas.value, 0, 0);
    ctx?.drawImage(path_canvas.value, 0, 0);
};

watchEffect(draw);
onUpdated(draw);

</script>

<template>
    <div class="flex justify-center items-center bg-base w-full h-[95%]">
        <input class="w-4/5 h-4/5 opacity-0 absolute" accept="image/png, image/jpeg" type="file" @change="updateFile" @click.prevent>
        <canvas ref="canvas" class="rounded border-outline border-2 max-w-[50vw] max-h-[50vh]" v-show="hasPicture"></canvas>
        <div v-if="!hasPicture" class="flex flex-col items-center">
            <i class="fa-solid fa-file-upload opacity-30 text-[10vw]"></i>
            <h1 class="opacity-30 text-center">Drag in the map here.</h1>
        </div>
    </div>
    <Draggable v-if="hasPicture" :bounds="canvas_bounds" @update="updateStart">
        <i class="fa-solid fa-location-crosshairs fa-2xl text-accent text-center"></i>
    </Draggable>
    <Draggable v-if="hasPicture" :bounds="canvas_bounds" :y_offset_percentage="-100" @update="updateEnd">
        <i class="fa-solid fa-location-pin fa-2xl text-accent-secondary text-center"></i>
    </Draggable>

    <button @click="processImage" class="bg-base border-outline z-10 rounded">Generate Path</button>
</template>