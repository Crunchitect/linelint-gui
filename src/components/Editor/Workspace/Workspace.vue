<script setup lang="ts">
    import { Tabs } from '@/lib/types';
    defineProps<{
        workspace: number
    }>();


    import None from './None.vue';
    import RobotMap from './RobotMap.vue';
    import NotSupported from './NotSupported.vue';
</script>

<template>
    <KeepAlive>
        <None v-if="workspace === Tabs.None" />
        <RobotMap v-else-if="workspace === Tabs.Map" />
        <NotSupported v-else />
    </KeepAlive>
</template>