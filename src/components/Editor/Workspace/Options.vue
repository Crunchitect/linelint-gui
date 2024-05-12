<script setup>
    import { heuristic, weight } from '@/config/pathfind';
    import Dropdown from '@/components/General/Dropdown.vue';
    import { ref } from 'vue';

    const methods = ref(['Manhattan', 'Euclidean', 'Chebyshev', 'Octile']);
    const descriptions = ref([
        'Best for maps with straight lines with a lot of corners.',
        'Best for maps with curves and turns.',
        'Best for maps with straight lines and diagonals.',
        'Best for maps with multiple goals, objectives.'
    ]);
    const icons = ref([
        'crop-simple',
        'ruler-combined',
        'crop',
        'compass-drafting'
    ]);
</script>

<template>
    <div class="bg-base w-full h-full rounded p-4">
        <h1 class="text-5xl font-bold mb-5">Pathfinding</h1>
        <div class="flex flex-col gap-2">
            <div class="flex justify-between text-4xl">
                <p>A* Heuristics Algorithm</p>
                <Dropdown v-model="heuristic">
                    <template #[method] v-for="(method, index) in methods">
                        <h2 class="font-bold"><i :class="`fa-solid fa-${icons[index]} fa-sm`"></i> &nbsp;{{ method }}</h2>
                        <p class="text-secondary text-xs">{{ descriptions[index] }}</p>
                    </template>
                </Dropdown>
            </div>
            <div class="flex justify-between text-4xl">
                <p>A* Heuristics Weight</p>
                <input class="rounded text-right w-[3em]" type="number" step="0.1" v-model="weight">
            </div>
        </div>
    </div>
</template>