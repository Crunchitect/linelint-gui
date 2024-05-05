<script setup lang="ts">
    import type { Tabs } from '@/lib/types';
    import { ref } from 'vue';
    const props = defineProps<{
        icon: string,
        id: number,
        type: Tabs
    }>();
    const emit = defineEmits<{
        close: [id: number],
        select: [type: Tabs]
    }>();

    const is_active = ref(false);
</script>

<template>
    <div @click="is_active = true" @focusout="is_active = false" class="mx-1 w-24 bg-base rounded flex justify-evenly items-center gap-1 before:content-[''] after:content-[''] opacity-40 has-[:checked]:opacity-100">
        <input type="radio" name="tab" :value="$slots[0]" @input="$emit('select', <Tabs>(type ?? 0))"  class="absolute w-full h-full opacity-0">
        <i :class="['fa-solid', `fa-${icon}`, 'text-center text-sm']"></i>
        <p><slot></slot></p>
        <i class="z-10 fa-solid fa-circle-xmark fa-xs text-red-300 hover:text-red-600" @click="$emit('close', <Tabs>(id ?? 0))"></i>
    </div>
</template>