" space to toggle folds
vnoremap <Space> za

" unmap `u` in visual mode since it's so close to y, remap `gu` to `u` for when it's needed
vnoremap u <nop>
vnoremap gu u

" substitute
vnoremap <c-s> :s/

" Visual shifting (does not exit Visual mode)
vnoremap < <gv
vnoremap > >gv

" use sane regex
vnoremap / /\v

" stard and end of line bindings
vnoremap L g_

" visual mode *
vnoremap * :<c-u>call <SID>VSetSearch()<cr>//<cr><c-o>
vnoremap # :<c-u>call <SID>VSetSearch()<cr>??<cr><c-o>

