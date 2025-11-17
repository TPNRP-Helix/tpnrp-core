export const formatWeight = (weight: number, unitText = {
    gram: 'gam',
    kg: 'kg',
    ton: 'ton'
}, isShowUnit = true) => {
    if (weight < 1000) {  
      return `${weight} ${isShowUnit ? unitText.gram : ''}`;
    } else if (weight < 1000000) {
      return `${(weight / 1000).toFixed(1)} ${isShowUnit ? unitText.kg : ''}`;
    } else {
      return `${(weight / 1000000).toFixed(1)} ${isShowUnit ? unitText.ton : ''}`;
    }
}
