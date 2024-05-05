export function filterMutate<T>(arr: T[], cb: (a: T) => boolean) {
    for (let l = arr.length - 1; l >= 0; l -= 1) {
        if (!cb(arr[l])) arr.splice(l, 1);
    }
}

export function slidingWindow(arr: any[], size: number) {
    return arr.reduce((acc: any[], _, i) => {
        if (i + size == arr.length) return acc;
        return acc.concat([arr.slice(i, i+3)]);
    }, [])
}