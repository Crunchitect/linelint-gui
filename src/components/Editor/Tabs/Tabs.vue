<script setup lang="ts">
    //@ts-ignore
    import Vuuri from 'vuuri';
    //@ts-ignore
    import Tab from '@/components/Editor/Tabs/Tab.vue';
    import { Tabs } from '@/lib/types';
    
    import { ref } from 'vue';
    import { filterMutate } from '@/lib/polyfill';

    const tabs = ref([
        { id: Math.random(), type: Tabs.Map, name: "Map", icon: "map" },
        { id: Math.random(), type: Tabs.Sensors, name: "Sensors", icon: "screwdriver-wrench" }
    ]);

    const create_new_tab = (type: Tabs, name: string, icon: string) => {
        tabs.value.push({
            id: Math.random(),
            type,
            name,
            icon
        });
    };

    defineEmits({
        select: (type: number) => {}
    })

    const newtab = ref(null as null | HTMLDialogElement);
</script>

<template>
    <div class="flex flex-row justify-between">
        <fieldset class="flex-grow">
            <Vuuri v-model="tabs" drag-enabled>
                <template #item="{ item: tab }">
                    <Tab :icon="tab.icon"
                         :id="tab.id"
                         :type="tab.type"
                         @close="id => filterMutate(tabs, tab => tab.id !== id)"
                         @select="type => $emit('select', type)"
                    >{{ tab.name }}</Tab>
                </template>
            </Vuuri>
        </fieldset>
        <button class="hover:bg-base rounded aspect-square w-[1lh]" @click="newtab?.showModal"><i class="fa-solid fa-plus"></i></button>
        <dialog ref="newtab" class="p-4 rounded border-outline border-2">
            <h1 class="text-primary text-2xl font-extrabold">New Tab</h1>
            <i class="z-10 fa-solid fa-circle-xmark text-red-300 hover:text-red-600 float-right" @click="newtab?.close"></i>
            <button></button>
            <h1 class="text-xl font-bold text-secondary">Main</h1>
            <div class="grid grid-cols-3 grid-rows-2 gap-1 w-[20vw]">
                <button class="bg-base rounded" @click="create_new_tab(Tabs.Map, 'Map', 'map')">Map</button>
                <button class="bg-base rounded" @click="create_new_tab(Tabs.Sensors, 'Sensors', 'screwdriver-wrench')">Sensors</button>
                <button class="bg-base rounded" @click="create_new_tab(Tabs.Options, 'Options', 'gear')">Options</button>
            </div>
        </dialog>
    </div>
</template>