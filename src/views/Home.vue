<script lang="ts" setup>
import Inspector from "@/components/Inspector.vue";    
import Editor from "@/components/Editor.vue";    
</script>


<template>
    <h1 class="text-primary text-4xl font-bold text-center p-4">Linelint</h1>
    <div class="flex flex-row flex-nowrap justify-evenly">
        <Inspector />
        <Editor />
    </div>
</template>