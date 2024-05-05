<script setup>
    import { heuristic } from '@/config/pathfind';
</script>

<template>
    <div class="bg-base w-full h-full rounded p-4">
        <h1 class="text-5xl font-bold mb-5">Pathfinding</h1>
        <div>
            <div class="flex justify-between text-4xl">
                <p>A* Heuristics Algorithm</p>
                <select v-model="heuristic" class="rounded">
                    <option>Manhattan</option>
                    <option>Euclidean</option>
                    <option>Chebyshev</option>
                    <option>Octile</option>
                </select>
            </div>
        </div>
    </div>
</template>