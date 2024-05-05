import { ref } from "vue"
import type { AStarHeuristics } from "@/lib/types"

export const heuristic = ref("Manhattan" as AStarHeuristics);
