<script setup lang="ts">
import { ref } from 'vue';
import { Tabs } from '@/lib/types';
import { skeletonize } from '@/lib/imageproc';

//@ts-ignore
import Vuuri from 'vuuri';
//@ts-ignore
import TabChip from '@/components/Editor/TabChip.vue';

const tabs = ref([
    { id: Tabs.Map, name: "Map", icon: "map" },
    { id: Tabs.Sensors, name: "Sensors", icon: "screwdriver-wrench" }
]);

const canvas = ref(null as null | HTMLCanvasElement);
const hasPicture = ref(false);

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

const processImage = () => {
    const context = canvas?.value?.getContext("2d");
    const empty_image = new ImageData(new Uint8ClampedArray([0, 0, 0, 0]), 1, 1);
    const { data, width, height } = context?.getImageData(0, 0, context.canvas.width, context.canvas.height) ?? empty_image;
    skeletonize(data, width, height);
};
</script>

<style scoped>

</style>


<template>
    <div class="flex flex-col justify-between w-4/5 h-[90vh]">
        <Vuuri v-model="tabs" drag-enabled>
            <template #item="{ item: tab }">
                <TabChip :icon="tab.icon">{{ tab.name }}</TabChip>
            </template>
        </Vuuri>
        <div class="flex justify-center items-center bg-base w-full h-[95%]">
            <input class="w-4/5 h-4/5 opacity-0 absolute" accept="image/png, image/jpeg" type="file" @change="updateFile" @click.prevent>
            <canvas ref="canvas" :class="[hasPicture ? 'rounded border-outline border-2' : '', 'max-w-[50vw] max-h-[50vh]']"></canvas>
            <button @click="processImage" class="bg-base border-outline border-2 z-10">Skeletonize</button>
        </div>
    </div>
</template>
