<script setup lang="ts">
import { ref } from 'vue';

//@ts-ignore
import Tabs from './Tabs/Tabs.vue';
//@ts-ignore
import Workspace from './Workspace/Workspace.vue'
import type { Tabs as TabsEnum } from '@/lib/types';

const selected = ref(0 as TabsEnum);

</script>

<template>
    <div class="flex flex-col justify-between w-4/5 h-[90vh] gap-2">
        <Tabs @select="type => selected = type" />
        <Workspace :workspace="selected" />
    </div>
</template>
