<script setup lang="ts">
import { ref } from 'vue';

const is_opened = ref(false);
const model = defineModel();

</script>

<template>
    <div class="flex flex-col">
        <div class="rounded bg-background min-h-[1lh] flex justify-between items-center p-2 transition-all" @click="is_opened = !is_opened"><p>{{ model }}</p> <i class="fa-solid fa-chevron-down fa-2xs"></i></div>
        <div class="bg-background rounded outline-outline outline-2 absolute translate-y-[1lh] -translate-x-10"  v-show="is_opened">
            <div v-for="name in Object.keys($slots)"  @click="() => {model = name; is_opened = false;}" class="p-2 select-none hover:bg-opacity-60">
                <slot :name="name"></slot>
            </div>
        </div>
    </div>
</template>