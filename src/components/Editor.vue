<script setup lang="ts">
import { ref } from 'vue';
import { Tabs } from '@/lib/types.ts';

import Vuuri from 'vuuri';
import TabChip from '@/components/Editor/TabChip.vue';

const tabs = ref([
    { id: Tabs.Map, name: "Map", icon: "map" },
    { id: Tabs.Sensors, name: "Sensors", icon: "screwdriver-wrench" }
]);

const canvas = ref(null);
const hasPicture = ref(false);

const updateFile = e => {
    hasPicture.value = true;
    const input = e.target;
    const file = input.files[0];
    const image = new Image();
    const reader = new FileReader();
    const context = canvas.value.getContext("2d");
    reader.readAsDataURL(file);
    reader.onload = e => {
        console.log(context)
        if (e.target.readyState == FileReader.DONE) {
            image.src = e.target.result;
            image.onload = function () {
                context.canvas.width = this.width;
                context.canvas.height = this.height;
                context.drawImage(image, 0, 0);
            }
        }
    };
};

const skeletonize = () => {
    const context = canvas.value.getContext("2d");
    const data = canvas.value.getImageData(0, 0, context.canvas.width, context.canvas.height);
    console.log(data);
};
</script>

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
            <button @click="skeletonize()">Skeletonize</button>
        </div>
    </div>
</template>
