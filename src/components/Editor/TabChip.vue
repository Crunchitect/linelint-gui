<script setup>
    defineProps({
        icon: String
    });
</script>

<template>
    <div class="bg-base rounded flex justify-evenly items-center gap-1 w-fit before:content-[''] after:content-['']">
        <i :class="['fa-solid', `fa-${icon}`, 'text-center']"></i>
        <p><slot></slot></p>
        <i class="fa-solid fa-circle-xmark fa-xs text-red-300 hover:text-red-500"></i>
    </div>
</template>