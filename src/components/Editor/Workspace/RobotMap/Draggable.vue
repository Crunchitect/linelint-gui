<script lang="ts" setup>
    import Moveable from 'vue3-moveable';
    import { ref, watch, type UnwrapRef} from 'vue';
    import type { OnDrag, OnDragEnd } from 'vue3-moveable';
    import type { UseElementBoundingReturn } from '@vueuse/core';
    
    type RefToReactive<Type> = {
        [Property in keyof Type]: UnwrapRef<Type[Property]>
    };
    
    const props = defineProps<{
        bounds: RefToReactive<UseElementBoundingReturn>
        x_offset_percentage?: number
        y_offset_percentage?: number
    }>();
        
    const emit = defineEmits<{
        update: [pos: [number, number]]
    }>();

    const movint = ref(null as null | HTMLSpanElement);

    const drag_callback = (e: OnDrag) => {
        const bounds = props.bounds;
        const left = Math.min(Math.max(e.translate[0], bounds?.left ?? 0), bounds?.right ?? 0);
        const top = Math.min(Math.max(e.translate[1], bounds?.top ?? 0), bounds?.bottom ?? 0);
        movint.value!.style.transform = ` translate(${left}px, ${top}px) translate(${props.x_offset_percentage ?? -50}%, ${props.y_offset_percentage ?? -50}%)`;
    };

    watch(props.bounds, (bounds) => {
        const { left, top, right, bottom } = bounds;
        const match = movint.value!.style.transform.match(/translate\((\d+)px, (\d+)px\)/g);
        if (match) {
            const [el_left, el_top] = match.map(v => Number(v));
            if ((left <= el_left && el_left <= right) && (top <= el_top && el_top < bottom)) {
                return;
            }
        } 
        if ((left & top & right & bottom) == 0) return;
        movint.value!.style.transform = ` translate(${left}px, ${top}px) translate(${props.x_offset_percentage ?? -50}%, ${props.y_offset_percentage ?? -50}%)`;
    });

    const update_pos = (e: OnDragEnd) => {
        const bounds = movint.value?.getBoundingClientRect() ?? new DOMRect();
        const x = bounds.left + (-(props.x_offset_percentage ?? -50) / 100 * bounds.width);
        const y = bounds.top + (-(props.x_offset_percentage ?? -50) / 100 * bounds.height);
        emit('update', [x, y]);
    };


</script>

<template>
    <span class="absolute top-0 left-0" ref="movint"><slot></slot></span>
    <KeepAlive>
    <Moveable :target="movint" :draggable="true" :throttle-drag="1" :hide-default-lines="true" :origin="false"
         @drag="drag_callback" @drag-end="update_pos"
        />
    </KeepAlive>
</template>