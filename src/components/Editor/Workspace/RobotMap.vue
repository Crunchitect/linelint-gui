<script setup lang="ts">
import Draggable from './RobotMap/Draggable.vue';
import { skeletonize, get_closest_black_pixel } from '@/lib/imageproc';
import { ref } from 'vue';
import { clamp } from '@vueuse/core';
import { useElementBounding, type UseElementBoundingReturn } from '@vueuse/core';

const canvas = ref(null as null | HTMLCanvasElement);
const canvas_bounds = ref(useElementBounding(canvas));
const hasPicture = ref(false);
const start = ref([0, 0]);
const end = ref([0, 0]);

const updateFile = (e: Event) => {
    hasPicture.value = true;
    const input = (<Event & {target: HTMLInputElement}>e).target;
    const file = input.files?.[0];
    const image = new Image();
    const reader = new FileReader();
    const context = canvas?.value?.getContext("2d");
    reader.readAsDataURL(file!);
    reader.onload = e => {
        if (e.target?.readyState == FileReader.DONE) {
            image.src = <string>e.target.result;
            image.onload = () => {
                context!.canvas.width = image.width;
                context!.canvas.height = image.height;
                context!.drawImage(image, 0, 0);
            }
        }
    };
};

const processImage = async () => {
    const context = canvas?.value?.getContext("2d");
    const empty_image = new ImageData(new Uint8ClampedArray([0, 0, 0, 0]), 1, 1);
    const { data, width, height } = context?.getImageData(0, 0, context.canvas.width, context.canvas.height) ?? empty_image;
    const thinned_image = await skeletonize(data, width, height);
    thinned_image.forEach((row, y) => row.forEach((pixel, x) => {
        context?.putImageData(new ImageData(new Uint8ClampedArray([pixel * 255, pixel * 255, pixel * 255, 255]), 1, 1), x, y)
    }))
    console.log("THINNED")
    const start_pos = await get_closest_black_pixel(width, height, Math.round(start.value[0]), Math.round(start.value[1]));
    const start_x = start_pos >> 32n;
    const start_y = start_pos & 0xFFFFFFFFn;
    console.log(start_x, start_y, start.value);

};

const updateStart = (pos: [number, number]) => {
    const { left, right, top, bottom, width, height } = canvas.value?.getBoundingClientRect() ?? new DOMRect();
    const ctx = canvas.value?.getContext("2d");
    const clamped_x = clamp(pos[0], left, right) - left;
    const clamped_y = clamp(pos[1], top, bottom) - top;
    start.value = [clamped_x / width * ctx!.canvas.width, clamped_y / height * ctx!.canvas.height];
};

const updateEnd = (pos: [number, number]) => {
    const { left, right, top, bottom } = canvas.value?.getBoundingClientRect() ?? new DOMRect();
    const clamped_x = clamp(pos[0], left, right) - left;
    const clamped_y = clamp(pos[1], top, bottom) - top;
    end.value = [clamped_x, clamped_y];
};

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